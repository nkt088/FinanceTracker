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

    //для листа
//    func categories() async throws -> [Category] {
//        cache.categories
//    }

    //для пикер
//    func categories(for direction: Direction) async throws -> [Category] {
//        cache.categories.filter { $0.direction == direction }
//    }

    func category(by id: Int) -> Category? {
        cache.categories.first(where: { $0.id == id })
    }
    
    //network
    //для View
    func categories() async throws -> [Category] {
        let response = try await NetworkService.shared.fetchAllCategories()
        return response.map { $0.toCategory }
    }
    //для Picker view
    func categories(for direction : Direction) async throws -> [Category] {
        let isIncome = direction == .income
        let response = try await NetworkService.shared.fetchCategories(isIncome: isIncome)
        return response.map { $0.toCategory }
    }
}
