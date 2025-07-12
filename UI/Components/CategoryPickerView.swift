//
//  CategoryPickerView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selected: Category?
    let direction: Direction

    @Environment(\.dismiss) private var dismiss

    @State private var categories: [Category] = []

    private let categoriesService = CategoriesService.shared

    var body: some View {
        List {
            ForEach(categories) { category in
                HStack {
                    Text("\(category.emoji) \(category.name)")
                    Spacer()
                    if selected?.id == category.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selected = category
                    dismiss()
                }
            }
        }
        .navigationTitle("Выберите статью")
        .task {
            do {
                categories = try await categoriesService.categories(for: direction)
            } catch {
                categories = []
            }
        }
    }
}
