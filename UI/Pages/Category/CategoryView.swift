//
//  CategoryView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredCategories) { category in
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
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .task {
                await viewModel.load()
            }
        }
    }
}
