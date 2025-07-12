//
//  TransactionsService.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

// MARK: - Transactions Service

import Foundation

final class TransactionsService {
    static let shared = TransactionsService()
    private let cache = TransactionsFileCache()
    private init() {
        try? cache.load(from: "transactions")
    }

    func transactions(from startDate: Date, to endDate: Date, accountId: Int) async throws -> [Transaction] {
        cache.transactions.filter {
            $0.account.id == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
    }

    func create(_ request: TransactionRequest) async throws -> Transaction {
        let new = Transaction(
            id: (cache.transactions.map { $0.id }.max() ?? 0) + 1,
            account: request.account,
            category: request.category,
            amount: request.amount,
            transactionDate: request.transactionDate,
            comment: request.comment,
            createdAt: Date(),
            updatedAt: Date()
        )
        cache.add(new)
        try? cache.save(to: "transactions")
        return new
    }

    func update(_ updated: Transaction) async throws -> Transaction {
        try await delete(id: updated.id)
        cache.add(updated)
        try? cache.save(to: "transactions")
        return updated
    }

    func delete(id: Int) async throws {
        cache.remove(by: id)
        try? cache.save(to: "transactions")
    }
}
