//
//  Transaction.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

// MARK: - Конвертация Transaction <-> Foundation
// Transaction+JSON
import Foundation

extension Transaction {
    var jsonObject: Any {
        var dict: [String: Any] = [
            "id": id,
            "account": [
                "id": account.id,
                "name": account.name,
                "balance": NSDecimalNumber(decimal: account.balance),
                "currency": account.currency
            ],
            "category": [
                "id": category.id,
                "name": category.name,
                "emoji": String(category.emoji),
                "isIncome": category.direction == .income
            ],
            "amount": NSDecimalNumber(decimal: amount),
            "transactionDate": transactionDate.timeIntervalSince1970,
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt.timeIntervalSince1970
        ]
        if let comment = comment {
            dict["comment"] = comment
        }
        return dict
    }

    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any],
              let id = dict["id"] as? Int,
              let amountRaw = dict["amount"],
              let transactionTimestamp = dict["transactionDate"] as? TimeInterval,
              let createdTimestamp = dict["createdAt"] as? TimeInterval,
              let updatedTimestamp = dict["updatedAt"] as? TimeInterval,
              let accountDict = dict["account"] as? [String: Any],
              let categoryDict = dict["category"] as? [String: Any],
              let account = parseAccountBrief(from: accountDict),
              let category = parseCategory(from: categoryDict)
        else {
            return nil
        }

        let comment = dict["comment"] as? String

        let amount: Decimal
        if let num = amountRaw as? NSNumber {
            amount = num.decimalValue
        } else if let str = amountRaw as? String, let decimal = Decimal(string: str) {
            amount = decimal
        } else {
            return nil
        }

        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: Date(timeIntervalSince1970: transactionTimestamp),
            comment: comment,
            createdAt: Date(timeIntervalSince1970: createdTimestamp),
            updatedAt: Date(timeIntervalSince1970: updatedTimestamp)
        )
    }

    private static func parseAccountBrief(from dict: [String: Any]) -> AccountBrief? {
        guard let id = dict["id"] as? Int,
              let name = dict["name"] as? String,
              let balanceRaw = dict["balance"],
              let currency = dict["currency"] as? String
        else { return nil }

        let balance: Decimal
        if let num = balanceRaw as? NSNumber {
            balance = num.decimalValue
        } else if let str = balanceRaw as? String, let decimal = Decimal(string: str) {
            balance = decimal
        } else {
            return nil
        }

        return AccountBrief(id: id, name: name, balance: balance, currency: currency)
    }

    private static func parseCategory(from dict: [String: Any]) -> Category? {
        guard let id = dict["id"] as? Int,
              let name = dict["name"] as? String,
              let emojiStr = dict["emoji"] as? String, let emoji = emojiStr.first,
              let isIncome = dict["isIncome"] as? Bool
        else { return nil }

        return Category(id: id, name: name, emoji: emoji, direction: isIncome ? .income : .outcome)
    }
}
