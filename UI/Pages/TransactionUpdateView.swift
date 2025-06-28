//
//  TransactionUpdateView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct TransactionUpdateView: View {
    enum Mode {
        case create
        case edit(Transaction)
    }

    @Environment(\.dismiss) private var dismiss

    let direction: Direction
    let mode: Mode

    @State private var selectedCategory: Category?
    @State private var amount: Decimal = 0
    @State private var date: Date = Date()
    @State private var comment: String = ""
    private var isCreate: Bool {
        if case .create = mode { return true }
        return false
    }

    private let categoriesService = MockCategoriesService()
    private let transactionsService = MockTransactionsService.shared
    private let account = AccountBrief(id: 1, name: "Основной счёт", balance: 0, currency: "RUB")
    
    var body: some View {
        Form {
            Section {
                NavigationLink(destination: CategoryPickerView(selected: $selectedCategory, direction: direction)) {
                    HStack {
                        Text("Статья")
                        Spacer()
                        if let category = selectedCategory {
                            Text(category.name)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                HStack {
                    Text("Сумма")
                    Spacer()
                    DecimalTextField(title: "", value: $amount)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120)
                }
                CustomDatePicker(title: "Дата", date: $date, components: .date)
                CustomDatePicker(title: "Время", date: $date, components: .hourAndMinute)
                TextField("Комментарий", text: $comment, axis: .vertical)
            }

            if case let .edit(transaction) = mode {
                Section {
                    DeleteTransactionButton(
                        transaction: transaction,
                        direction: direction,
                        onDelete: { dismiss() }
                    )
                }
            }
        }
        .navigationTitle(isCreate ? "Новая операция" : "Мои \(direction == .income ? "Доходы" : "Расходы")")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    Task {
                        await save()
                        dismiss()
                    }
                }.disabled(selectedCategory == nil || amount <= 0)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") {
                    dismiss()
                }
            }
        }
        .task {
            if case let .edit(transaction) = mode {
                selectedCategory = transaction.category
                amount = transaction.amount
                date = transaction.transactionDate
                comment = transaction.comment ?? ""
            }
        }
    }

    private func save() async {
        guard let category = selectedCategory else { return }
        let request = TransactionRequest(
            account: account,
            category: category,
            amount: amount,
            transactionDate: date,
            comment: comment.isEmpty ? nil : comment
        )
        switch mode {
        case .create:
            _ = try? await transactionsService.create(request)
        case .edit(let transaction):
            let updated = Transaction(
                id: transaction.id,
                account: account,
                category: category,
                amount: amount,
                transactionDate: date,
                comment: comment,
                createdAt: transaction.createdAt,
                updatedAt: Date()
            )
            _ = try? await transactionsService.update(updated)
        }
    }
}
