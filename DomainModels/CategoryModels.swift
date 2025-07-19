//
//  Category.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
// MARK: - Category Models

import Foundation

struct StatItem {
    let categoryId: Int
    let categoryName: String
    let emoji: String
    let amount: Decimal
}

struct Category : Identifiable, Hashable {
    let id: Int
    let name: String
    let emoji: String
    let direction: Direction
}

struct CategoryResponse: Decodable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool

    var toCategory: Category {
        Category(
            id: id,
            name: name,
            emoji: emoji,
            direction: isIncome ? .income : .outcome
        )
    }
}
extension Category: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case isIncome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)

        let isIncome = try container.decode(Bool.self, forKey: .isIncome)
        direction = isIncome ? .income : .outcome
    }
}
