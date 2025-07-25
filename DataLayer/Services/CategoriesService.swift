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
//    func categories(for direction : Direction) async throws -> [Category] {
//        let isIncome = direction == .income
//        let response = try await NetworkService.shared.fetchCategories(isIncome: isIncome)
//        return response.map { $0.toCategory }
//    }
    func categories(for direction: Direction) async throws -> [Category] {
        let isIncome = direction == .income

        // Проверка наличия локального файла
        let fileExists = (try? cache.fileURL(for: "categories"))
            .map { FileManager.default.fileExists(atPath: $0.path) } ?? false

        // Если офлайн и файл существует — загружаем из файла
        if !NetworkMonitor.shared.isConnected, fileExists {
            return cache.categories.filter { $0.direction == direction }
        }

        do {
            // Пробуем получить с сервера
            let response = try await NetworkService.shared.fetchCategories(isIncome: isIncome)
            let categories = response.map { $0.toCategory }

            // Загружаем все категории для обновления кэша
            let all = try await NetworkService.shared.fetchAllCategories()
            cache.set(all.map { $0.toCategory })
            try cache.save(to: "categories")

            return categories
        } catch {
            // Если не удалось получить с сервера, но есть файл — fallback
            if fileExists {
                return cache.categories.filter { $0.direction == direction }
            } else {
                throw error
            }
        }
    }
}
