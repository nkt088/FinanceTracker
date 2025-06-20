//
//  TransactionsFileCache.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

// MARK: - TransactionsFileCache

import Foundation

final class TransactionsFileCache {
    private(set) var transactions: [Transaction] = []
    private let fileManager = FileManager.default

    func add(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }

    func remove(by id: Int) {
        transactions.removeAll { $0.id == id }
    }

    func save(to fileName: String) throws {
        let array = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
        let url = try fileURL(for: fileName)
        try data.write(to: url)
    }

    func load(from fileName: String) throws {
        let url = try fileURL(for: fileName)
        guard fileManager.fileExists(atPath: url.path) else {
            transactions = []
            return
        }

        let data = try Data(contentsOf: url)
        let raw = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
        var loaded: [Transaction] = []

        for item in raw {
            if let tx = Transaction.parse(jsonObject: item),
               !loaded.contains(where: { $0.id == tx.id }) {
                loaded.append(tx)
            }
        }

        transactions = loaded
    }

    func sortedByDateDescending() -> [Transaction] {
        transactions.sorted { $0.transactionDate > $1.transactionDate }
    }

    private func fileURL(for fileName: String) throws -> URL {
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Document directory not found"])
        }
        return directory.appendingPathComponent(fileName).appendingPathExtension("json")
    }
}
