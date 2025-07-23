//
//  Account.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

//extension Account {
//    var jsonObject: Any {
//        [
//            "balance": NSDecimalNumber(decimal: balance).stringValue
//        ]
//    }
//
//    static func parse(jsonObject: Any) -> Account? {
//        guard let dict = jsonObject as? [String: Any],
//              let balanceStr = dict["balance"] as? String,
//              let balance = Decimal(string: balanceStr)
//        else {
//            return nil
//        }
//
//        return Account(
//            id: 1,
//            userId: 1,
//            name: "Основной счёт",
//            balance: balance,
//            currency: "RUB",
//            createdAt: Date(),
//            updatedAt: Date()
//        )
//    }
//}
