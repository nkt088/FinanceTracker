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
        [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": NSDecimalNumber(decimal: amount).stringValue,
            "transactionDate": transactionDate.timeIntervalSince1970,
            "comment": comment ?? "",
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt.timeIntervalSince1970
        ]
    }

    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any],
              let id = dict["id"] as? Int,
              let accountId = dict["accountId"] as? Int,
              let categoryId = dict["categoryId"] as? Int,
              let amountStr = dict["amount"] as? String,
              let amount = Decimal(string: amountStr),
              let transactionDate = dict["transactionDate"] as? TimeInterval,
              let createdAt = dict["createdAt"] as? TimeInterval,
              let updatedAt = dict["updatedAt"] as? TimeInterval
        else {
            return nil
        }

        let comment = (dict["comment"] as? String)?.isEmpty == false ? dict["comment"] as? String : nil

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: Date(timeIntervalSince1970: transactionDate),
            comment: comment,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}
