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
            await loadTransactions()
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
            transactions = TransactionSorter.sort(filtered, by: sortMode)
        } catch {
            transactions = []
        }

        isLoading = false
    }

    private func reload() {
        Task {
            await loadTransactions()
        }
    }
}
