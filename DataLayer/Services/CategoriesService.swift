//
//  CategoriesService.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

// MARK: - Category Service

import Foundation

final class CategoriesService {
    static let shared = CategoriesService()

    private let cache = CategoriesFileCache()
    private init() {
        try? cache.load(from: "categories")
    }

    func categories() async throws -> [Category] {
        cache.categories
    }

    func categories(for direction: Direction) async throws -> [Category] {
        cache.categories.filter { $0.direction == direction }
    }
}
