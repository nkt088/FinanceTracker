//
//  TransactionsListView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    @State private var transactions: [Transaction] = []
    @State private var isLoading = true
    @State private var showAddScreen = false
    @State private var editingTransaction: Transaction?
    @State private var sortMode: SortModeTransaction = .byDate

    private let service = TransactionsService.shared
    private let categoriesService = CategoriesService.shared

    @State private var categoriesMap: [Int: Category] = [:]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .padding()

            AddTransactionButton {
                showAddScreen = true
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .fullScreenCover(isPresented: $showAddScreen, onDismiss: reload) {
            NavigationStack {
                TransactionUpdateView(direction: direction, mode: .create)
            }
        }
        .fullScreenCover(item: $editingTransaction, onDismiss: reload) { tx in
            NavigationStack {
                TransactionUpdateView(direction: direction, mode: .edit(tx))
            }
        }
        .onChange(of: sortMode) {
            transactions = TransactionSorter.sort(transactions, by: sortMode)
        }
        .task {
            
            await ensureLocalDataExists() // первичная загрузка

            await loadData()
        }
    }

    private var content: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                NavigationLink(destination:
                    TransactionsHistoryView(direction: direction)
                        .navigationBarBackButtonHidden(true)
                ) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            HStack {
                Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                    .font(.largeTitle.bold())
                Spacer()
            }

            HStack {
                Text("Сортировка")
                    .font(.subheadline)
                Spacer()
                Picker("", selection: $sortMode) {
                    ForEach(SortModeTransaction.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }

            HStack {
                Text("Всего")
                    .font(.headline)
                Spacer()
                Text(totalAmount.formatted(.currency(code: "RUB").locale(Locale(identifier: "ru_RU"))))
                    .font(.headline)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text("Операции")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(transactions) { tx in
                            Button {
                                editingTransaction = tx
                            } label: {
                                TransactionRowView(transaction: tx, category: categoriesMap[tx.categoryId])
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading)
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }

    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        let calendar = Calendar.current
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        let start = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!

        guard let accountId = AccountManager.shared.accountId ?? AccountManager.shared.cachedAccountId else {
            print("accountId недоступен")
            transactions = []
            return
        }

        do {
            let all = try await service.transactions(from: start, to: end)
            let allCategories = try await categoriesService.categories(for: direction)
            let categoryIds = Set(allCategories.map(\.id))
            categoriesMap = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })

            let filtered = all.filter { categoryIds.contains($0.categoryId) }
            transactions = TransactionSorter.sort(filtered, by: sortMode)
        } catch {
            print("Ошибка загрузки транзакций: \(error)")
            transactions = []
        }
    }

    private func reload() {
        Task {
            await loadData()
        }
    }
    private func ensureLocalDataExists() async {
        guard NetworkMonitor.shared.isConnected else { return }

        let fileURL: URL
        do {
            fileURL = try FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("transactions.json")
        } catch {
            return
        }

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let calendar = Calendar.current
            let start = calendar.date(byAdding: .year, value: -1, to: Date())!
            let end = calendar.date(byAdding: .day, value: 1, to: Date())!
            guard let accountId = AccountManager.shared.accountId ?? AccountManager.shared.cachedAccountId else { return }
            do {
                let transactions = try await NetworkService.shared.fetchTransactions(accountId: accountId, startDate: start, endDate: end)
                let txModels = transactions.map { $0.toTransaction() }

                let fileCache = TransactionsFileCache()
                txModels.forEach { fileCache.add($0) }
                try? fileCache.save(to: "transactions")
            } catch {
                // игнорируем, если не удалось
            }
        }
    }
}
