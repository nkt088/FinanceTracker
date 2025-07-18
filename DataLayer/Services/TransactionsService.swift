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
    //для net протестить без него
    private init() {}
    //для json
//    private init() {
//        try? cache.load(from: "transactions")
//    }

//    func transactions(from startDate: Date, to endDate: Date, accountId: Int) async throws -> [Transaction] {
//        cache.transactions.filter {
//            $0.accountId == accountId &&
//            $0.transactionDate >= startDate &&
//            $0.transactionDate <= endDate
//        }
//    }
//для json
//    func create(_ request: TransactionRequest) async throws -> Transaction {
//        let new = Transaction(
//            id: (cache.transactions.map { $0.id }.max() ?? 0) + 1,
//            accountId: request.accountId,
//            categoryId: request.categoryId,
//            amount: request.amount,
//            transactionDate: request.transactionDate,
//            comment: request.comment,
//            createdAt: Date(),
//            updatedAt: Date()
//        )
//        cache.add(new)
//        try? cache.save(to: "transactions")
//        return new
//    }

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
    
    
    //network create
    func create(_ request: TransactionRequest) async throws -> Transaction {
        try await NetworkService.shared.createTransaction(request)
    }
    //вывод на ListView
    func transactions(from start: Date, to end: Date, accountId: Int = 104) async throws -> [Transaction] {
        let responses = try await NetworkService.shared.fetchTransactions(accountId: accountId, startDate: start, endDate: end)
        return responses.map { $0.toTransaction() }
    }
}
