//
//  CategoryModel.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var allCategories: [Category] = []
    @Published var searchText: String = ""
    @Published var errorMessage: String?

    private let service = CategoriesService.shared
    private let fileName = "categories"
    private let cache = CategoriesFileCache()
    private let monitor = NetworkMonitor.shared

    var filteredCategories: [Category] {
        guard !searchText.isEmpty else { return allCategories }
        return allCategories.filter { $0.name.fuzzyMatch(searchText) }
    }

    func loadCategories() async {
        do {
            let url = try cache.fileURL(for: fileName)
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            // Нет файла и нет интернета — показываем ошибку и выходим
            if !fileExists && !monitor.isConnected {
                errorMessage = "Подключитесь к интернету для продолжения работы"
                allCategories = []
                return
            }
            // Если файл есть — пробуем загрузить из него в любом случае
            if fileExists {
                try cache.load(from: fileName)
                allCategories = cache.categories
            }
            // Если есть интернет — загружаем с сервера и сохраняем
            if monitor.isConnected {
                let responses = try await NetworkService.shared.fetchAllCategories()
                let categories = responses.map { $0.toCategory }
                cache.set(categories)
                try cache.save(to: fileName)
                allCategories = categories
            }

            errorMessage = nil
        } catch {
            allCategories = []
        }
    }
}
