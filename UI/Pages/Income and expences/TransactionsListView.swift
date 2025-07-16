//
//  TransactionsListView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
import SwiftUI

struct TransactionsListView: View {
    
    enum SortOption: String, CaseIterable, Identifiable {
        case byDate = "По дате"
        case byAmount = "По сумме"

        var id: Self { self }
    }
    let direction: Direction
    @State private var transactions: [Transaction] = []
    @State private var isLoading = true
    @State private var showAddScreen = false
    @State private var editingTransaction: Transaction?
    @State private var sortOption: SortOption = .byDate

    private let service = TransactionsService.shared

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
        .onChange(of: sortOption) {
            transactions = sortTransactions(transactions)
        }
        .task {
            await loadTransactions()
        }
    }

    private var content: some View {
        VStack(spacing: 16) {
            // Верхняя кнопка
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

            // Заголовок
            HStack {
                Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                    .font(.largeTitle.bold())
                Spacer()
            }
            HStack {
                Text("Сортировка")
                    .font(.subheadline)
                Spacer()
                Picker("", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            // Всего
            HStack {
                Text("Всего")
                    .font(.headline)
                Spacer()
                Text(totalAmount.formatted(.currency(code: "RUB")
                                                .locale(Locale(identifier: "ru_RU"))
                                          ))
                    .font(.headline)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Подзаголовок
            Text("Операции")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Список
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
                                TransactionRowView(transaction: tx)
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

    private func loadTransactions() async {
        isLoading = true
        let today = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        do {
            let all = try await service.transactions(from: today, to: end, accountId: 1)
            let filtered = all.filter { $0.category.direction == direction }
            transactions = sortTransactions(filtered)
        } catch {
            transactions = []
        }

        isLoading = false
    }
    private func sortTransactions(_ list: [Transaction]) -> [Transaction] {
        switch sortOption {
        case .byDate:
            return list.sorted { $0.transactionDate > $1.transactionDate }
        case .byAmount:
            return list.sorted { $0.amount > $1.amount }
        }
    }
    private func reload() {
        Task {
            await loadTransactions()
        }
    }
}
