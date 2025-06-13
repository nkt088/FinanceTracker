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
            "accountId": accountId,
            "categoryId": categoryId,
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
              let accountId = dict["accountId"] as? Int,
              let categoryId = dict["categoryId"] as? Int,
              let amountRaw = dict["amount"],
              let transactionTimestamp = dict["transactionDate"] as? TimeInterval,
              let createdTimestamp = dict["createdAt"] as? TimeInterval,
              let updatedTimestamp = dict["updatedAt"] as? TimeInterval
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
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: Date(timeIntervalSince1970: transactionTimestamp),
            comment: comment,
            createdAt: Date(timeIntervalSince1970: createdTimestamp),
            updatedAt: Date(timeIntervalSince1970: updatedTimestamp)
        )
    }
}
