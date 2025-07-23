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

struct TransactionResponse: Decodable {
    let id: Int
    let account: AccountBrief
    let category: Category
    let amount: String
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date

    func toTransaction() -> Transaction {
        Transaction(
            id: id,
            accountId: account.id,
            categoryId: category.id,
            amount: Decimal(string: amount) ?? 0,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
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

extension Transaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        accountId = try container.decode(Int.self, forKey: .accountId)
        categoryId = try container.decode(Int.self, forKey: .categoryId)

        let amountString = try container.decode(String.self, forKey: .amount)
        guard let amountDecimal = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(forKey: .amount, in: container, debugDescription: "Invalid decimal string")
        }
        amount = amountDecimal

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        guard let parsedTransactionDate = dateFormatter.date(from: try container.decode(String.self, forKey: .transactionDate)) else {
            throw DecodingError.dataCorruptedError(forKey: .transactionDate, in: container, debugDescription: "Invalid transactionDate")
        }
        transactionDate = parsedTransactionDate

        // createdAt и updatedAt могут отсутствовать в ответе на создание — обрабатываем безопасно
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
           let parsedCreatedAt = dateFormatter.date(from: createdAtString) {
            createdAt = parsedCreatedAt
        } else {
            createdAt = transactionDate // или Date()
        }

        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt),
           let parsedUpdatedAt = dateFormatter.date(from: updatedAtString) {
            updatedAt = parsedUpdatedAt
        } else {
            updatedAt = transactionDate // или Date()
        }

        comment = try container.decodeIfPresent(String.self, forKey: .comment)
    }
}
