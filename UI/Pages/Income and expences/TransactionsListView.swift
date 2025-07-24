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
            if AccountFileCache.shared.current() == nil {
                if NetworkMonitor.shared.isConnected {
                    if let remote = try? await NetworkService.shared.fetchAccount() {
                        try? BankAccountsService.shared.saveLoadedAccount(remote)
                        AccountManager.shared.setAccountId(remote.id)
                    }
                }
            }
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
        let calendar = Calendar.current
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        let start = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
        let accountId = AccountManager.shared.accountId
//        var calendar = Calendar.current
//        calendar.timeZone = TimeZone.current
//        
//        let today = calendar.startOfDay(for: Date())
//        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)!
        do {
            //для json
            //let all = try await service.transactions(from: today, to: end, accountId: 1)
            //для network
            let all = try await service.transactions(from: start, to: end, accountId: accountId!)
            // получить нужные категории по direction
            let allCategories = try await categoriesService.categories(for: direction)
            let categoryIds = Set(allCategories.map(\.id))
            categoriesMap = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })

            // фильтрация по categoryId
            let filtered = all.filter { categoryIds.contains($0.categoryId) }
            transactions = TransactionSorter.sort(filtered, by: sortMode)
        } catch {
            transactions = []
        }

        isLoading = false
    }

    private func reload() {
        Task {
            await loadData()
        }
    }
}
