//
//  Transaction+CSV.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation
//Transaction+CSV
extension Transaction {
    static let csvHeader = "id,accountId,categoryId,amount,transactionDate,comment,createdAt,updatedAt"

    var csvString: String {
        let fields: [String] = [
            String(id),
            String(accountId),
            String(categoryId),
            String(describing: amount),
            iso8601String(from: transactionDate),
            comment?.replacingOccurrences(of: "\"", with: "\"\"").wrappedInQuotes ?? "",
            iso8601String(from: createdAt),
            iso8601String(from: updatedAt)
        ]
        return fields.joined(separator: ",")
    }

    static func parse(csvLine: String) -> Transaction? {
        let parts = csvLine.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 8 else { return nil }

        guard
            let id = Int(parts[0]),
            let accountId = Int(parts[1]),
            let categoryId = Int(parts[2]),
            let amount = Decimal(string: parts[3]),
            let transactionDate = iso8601Date(from: parts[4]),
            let createdAt = iso8601Date(from: parts[6]),
            let updatedAt = iso8601Date(from: parts[7])
        else {
            return nil
        }

        let comment = parts[5].unwrappedFromQuotes

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment.isEmpty ? nil : comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Helpers

    private func iso8601String(from date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    private static func iso8601Date(from string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }
}

private extension String {
    var wrappedInQuotes: String {
        "\"\(self)\""
    }

    var unwrappedFromQuotes: String {
        trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            .replacingOccurrences(of: "\"\"", with: "\"")
    }
}
