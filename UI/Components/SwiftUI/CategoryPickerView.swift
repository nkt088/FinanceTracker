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

    private let fileName = "categories"
    private let cache = CategoriesFileCache()
    private let monitor = NetworkMonitor.shared

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
            await loadCategories()
        }
    }

    private func loadCategories() async {
        do {
            let url = try cache.fileURL(for: fileName)
            let fileExists = FileManager.default.fileExists(atPath: url.path)

            // Если нет файла и нет интернета — ничего не делаем
            if !fileExists && !monitor.isConnected {
                categories = []
                return
            }

            // Если файл есть — загружаем из него
            if fileExists {
                try cache.load(from: fileName)
                categories = cache.all(for: direction)
            }

            // Если интернет есть — загружаем с сервера, сохраняем и обновляем список
            if monitor.isConnected {
                let responses = try await NetworkService.shared.fetchAllCategories()
                let all = responses.map { $0.toCategory }
                cache.set(all)
                try cache.save(to: fileName)
                categories = all.filter { $0.direction == direction }
            }
        } catch {
            categories = []
        }
    }
}
