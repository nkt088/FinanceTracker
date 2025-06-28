//
//  TransactionsMock.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

final class MockTransactionsService {
    // фрагмент чтобы обновлять изменения
    static let shared = MockTransactionsService()
    private init() {}
    //
    private var transactions: [Transaction] = [
        // Доходы
        Transaction(
            id: 1,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 10, name: "Зарплата", emoji: "💼", direction: .income),
            amount: 300_000,
            transactionDate: Date(),
            comment: "Зарплата за май",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 2,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 11, name: "Подработка", emoji: "🛠️", direction: .income),
            amount: 100_000,
            transactionDate: Date(),
            comment: "Фриланс",
            createdAt: Date(),
            updatedAt: Date()
        ),

        // Расходы (по макету)
        Transaction(
            id: 3,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 1, name: "Аренда квартиры", emoji: "🏠", direction: .outcome),
            amount: 20_000,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 4,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 2, name: "Одежда", emoji: "👚", direction: .outcome),
            amount: 30_000,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 5,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 3, name: "На собачку", emoji: "🐶", direction: .outcome),
            amount: 80_000,
            transactionDate: Date(),
            comment: "Джек",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 6,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 3, name: "На собачку", emoji: "🐶", direction: .outcome),
            amount: 90_000,
            transactionDate: Date(),
            comment: "Энни",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 7,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 4, name: "Ремонт квартиры", emoji: "🛠", direction: .outcome),
            amount: 200_000,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 8,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 5, name: "Продукты", emoji: "🍏", direction: .outcome),
            amount: 10_000,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 9,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: 1000.0, currency: "RUB"),
            category: Category(id: 6, name: "Спортзал", emoji: "🏋️", direction: .outcome),
            amount: 10_000,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]

    func transactions(from startDate: Date, to endDate: Date, accountId: Int) async throws -> [Transaction] {
        transactions.filter {
            $0.account.id == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
    }

    func create(_ request: TransactionRequest) async throws -> Transaction {
        let new = Transaction(
            id: (transactions.map { $0.id }.max() ?? 0) + 1,
            account: request.account,
            category: request.category,
            amount: request.amount,
            transactionDate: request.transactionDate,
            comment: request.comment,
            createdAt: Date(),
            updatedAt: Date()
        )
        transactions.append(new)
        return new
    }

    func update(_ updated: Transaction) async throws -> Transaction {
        guard let index = transactions.firstIndex(where: { $0.id == updated.id }) else {
            throw NSError(domain: "MockTransactionsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
        }
        transactions[index] = updated
        return updated
    }

    func delete(id: Int) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "MockTransactionsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
        }
        transactions.remove(at: index)
    }
}
