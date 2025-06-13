//
//  TransactionsService.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

// MARK: - Transactions Service

import Foundation

final class TransactionsService {
    private var transactions: [Transaction] = []

    func transactions(from startDate: Date, to endDate: Date, accountId: Int) async throws -> [Transaction] {
        transactions.filter {
            $0.accountId == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
    }

    func create(_ request: TransactionRequest) async throws -> Transaction {
        let new = Transaction(
            id: (transactions.map { $0.id }.max() ?? 0) + 1,
            accountId: request.accountId,
            categoryId: request.categoryId,
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
            throw NSError(domain: "TransactionService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
        }
        transactions[index] = updated
        return updated
    }

    func delete(id: Int) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "TransactionService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
        }
        transactions.remove(at: index)
    }
}
