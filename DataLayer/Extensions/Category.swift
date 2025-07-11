//
//  Category.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

extension Category {
    var jsonObject: Any {
        [
            "id": id,
            "name": name,
            "emoji": String(emoji),
            "isIncome": direction == .income
        ]
    }

    static func parse(jsonObject: Any) -> Category? {
        guard let dict = jsonObject as? [String: Any],
              let id = dict["id"] as? Int,
              let name = dict["name"] as? String,
              let emojiStr = dict["emoji"] as? String, let emoji = emojiStr.first,
              let isIncome = dict["isIncome"] as? Bool
        else { return nil }

        return Category(id: id, name: name, emoji: emoji, direction: isIncome ? .income : .outcome)
    }
}
