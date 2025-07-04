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
    let emoji: Character
    let amount: Decimal
}

struct Category : Identifiable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
}
