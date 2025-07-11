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

    private let service = CategoriesService.shared

    var filteredCategories: [Category] {
        guard !searchText.isEmpty else { return allCategories }
        return allCategories.filter {
            $0.name.fuzzyMatch(searchText)
        }
    }

    func load() async {
        do {
            allCategories = try await service.categories()
        } catch {
            allCategories = []
        }
    }
}

