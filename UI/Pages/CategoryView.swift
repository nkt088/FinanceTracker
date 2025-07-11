//
//  CategoryView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct CategoryView: View {
    @State private var allCategories: [Category] = []
    @State private var searchText: String = ""

    private let service = CategoriesService.shared

    var filteredCategories: [Category] {
        guard !searchText.isEmpty else { return allCategories }
        return allCategories.filter {
            $0.name.fuzzyMatch(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredCategories) { category in
                        CategoryRowView(category: category)
                        Divider().padding(.leading)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Мои статьи")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .task {
                do {
                    allCategories = try await service.categories()
                } catch {
                    allCategories = []
                }
            }
        }
    }
}
