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
    private let fileName = "transactions"

    private init() {
        try? cache.load(from: fileName)
    }

    func transactions(from start: Date, to end: Date) async throws -> [Transaction] {
        guard let accountId = AccountManager.shared.cachedAccountId else {
            throw NSError(domain: "AccountError", code: 1, userInfo: [NSLocalizedDescriptionKey: "accountId не найден в UserDefaults"])
        }
        if NetworkMonitor.shared.isConnected {
            let responses = try await NetworkService.shared.fetchTransactions(accountId: accountId, startDate: start, endDate: end)
            let transactions = responses.map { $0.toTransaction() }

            // обновим локальный файл
            transactions.forEach { cache.add($0) }
            try? cache.save(to: fileName)
            return transactions
        } else {
            return cache.transactions.filter {
                $0.accountId == accountId && $0.transactionDate >= start && $0.transactionDate <= end
            }
        }
    }

    func create(_ request: TransactionRequest) async throws -> Transaction {
        let transaction: Transaction

        if NetworkMonitor.shared.isConnected {
            transaction = try await NetworkService.shared.createTransaction(request)
        } else {
            let newId = (cache.transactions.map { $0.id }.max() ?? 0) + 1
            transaction = Transaction(
                id: newId,
                accountId: request.accountId,
                categoryId: request.categoryId,
                amount: request.amount,
                transactionDate: request.transactionDate,
                comment: request.comment,
                createdAt: request.transactionDate,
                updatedAt: Date()
            )
        }

        cache.add(transaction)
        try? cache.save(to: fileName)
        return transaction
    }

    func update(_ id: Int, with request: TransactionRequest) async throws -> Transaction {
        let updated = Transaction(
            id: id,
            accountId: request.accountId,
            categoryId: request.categoryId,
            amount: request.amount,
            transactionDate: request.transactionDate,
            comment: request.comment,
            createdAt: request.transactionDate,
            updatedAt: Date()
        )

        if NetworkMonitor.shared.isConnected {
            _ = try await NetworkService.shared.updateTransaction(id: id, request)
        }

        try await delete(id: id)
        cache.add(updated)
        try? cache.save(to: fileName)

        return updated
    }

    func delete(id: Int) async throws {
        if NetworkMonitor.shared.isConnected {
            try await NetworkService.shared.deleteTransaction(id: id)
        }

        cache.remove(by: id)
        try? cache.save(to: fileName)
    }
}
