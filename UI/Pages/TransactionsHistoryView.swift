//
//  TransactionsHistoryView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct TransactionsHistoryView: View {
    let direction: Direction
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var transactions: [Transaction] = []
    @State private var isLoading = false

    private let service = MockTransactionsService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Text("Моя история")
                        .font(.largeTitle.bold())
                    Spacer()
                }

                HStack {
                    Text("Начало")
                    Spacer()
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                }

                HStack {
                    Text("Конец")
                    Spacer()
                    DatePicker("", selection: $endDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                }

                HStack {
                    Text("Сумма")
                        .font(.headline)
                    Spacer()
                    Text(totalAmount.formatted(.currency(code: "RUB")))
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

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
                                TransactionRowView(transaction: tx)
                                Divider().padding(.leading)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Назад") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // заглушка
                    } label: {
                        Image(systemName: "doc")
                    }
                }
            }
        }
        //Задание со *
        .onChange(of: startDate) {
            if startDate > endDate {
                endDate = startDate
            }
            reload()
        }
        .onChange(of: endDate) {
            if endDate < startDate {
                startDate = endDate
            }
            reload()
        }
        .task {
            await load()
        }
    }

    private var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }

    private func reload() {
        Task {
            await load()
        }
    }

    private func load() async {
        isLoading = true
        let startOfStart = Calendar.current.startOfDay(for: startDate)
        let endOfEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!

        do {
            let all = try await service.transactions(from: startOfStart, to: endOfEnd, accountId: 1)
            transactions = all.filter { $0.category.direction == direction }
        } catch {
            transactions = []
        }

        isLoading = false
    }
}
