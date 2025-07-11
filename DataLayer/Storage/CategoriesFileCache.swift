//
//  CategoriesFileCache.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

final class CategoriesFileCache {
    private(set) var categories: [Category] = []
    private let fileManager = FileManager.default

    func add(_ category: Category) {
        guard !categories.contains(where: { $0.id == category.id }) else { return }
        categories.append(category)
    }

    func save(to fileName: String) throws {
        let array = categories.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
        let url = try fileURL(for: fileName)
        try data.write(to: url)
    }

    func load(from fileName: String) throws {
        let url = try fileURL(for: fileName)
        guard fileManager.fileExists(atPath: url.path) else {
            categories = []
            return
        }

        let data = try Data(contentsOf: url)
        let raw = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
        var loaded: [Category] = []

        for item in raw {
            if let category = Category.parse(jsonObject: item),
               !loaded.contains(where: { $0.id == category.id }) {
                loaded.append(category)
            }
        }

        categories = loaded
    }

    func all(for direction: Direction) -> [Category] {
        categories.filter { $0.direction == direction }
    }

    private func fileURL(for fileName: String) throws -> URL {
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Document directory not found"])
        }
        return directory.appendingPathComponent(fileName).appendingPathExtension("json")
    }
}
