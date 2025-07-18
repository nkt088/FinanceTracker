//
//  Transaction.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
// MARK: - Transaction Models
import Foundation

struct Transaction : Identifiable{
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}

struct TransactionRequest {
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
}

struct TransactionResponse {
    let id: Int
    let account: AccountBrief
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}

extension TransactionRequest: Encodable {
    enum CodingKeys: String, CodingKey {
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(String(describing: amount), forKey: .amount)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let dateString = formatter.string(from: transactionDate)
        try container.encode(dateString, forKey: .transactionDate)
        try container.encode(comment ?? "", forKey: .comment)
    }
}

struct EmptyResponse: Decodable {}
