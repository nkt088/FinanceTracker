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
