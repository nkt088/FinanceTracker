//
//  AccountFileCache.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

final class AccountFileCache {
    static let shared = AccountFileCache()
    private init() {}

    private let fileManager = FileManager.default
    private let fileName = "account"
    private var account: Account?

//    func save(_ account: Account) throws {
//        let object = account.jsonObject
//        let data = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
//        let url = try fileURL()
//        try data.write(to: url)
//        self.account = account
//    }
//
//    func load() throws {
//        let url = try fileURL()
//        guard fileManager.fileExists(atPath: url.path) else {
//            self.account = nil
//            return
//        }
//
//        let data = try Data(contentsOf: url)
//        let raw = try JSONSerialization.jsonObject(with: data, options: [])
//        self.account = Account.parse(jsonObject: raw)
//    }
    func save(_ account: Account) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(account)
        let url = try fileURL()
        try data.write(to: url)
        self.account = account
    }

    func load() throws {
        let url = try fileURL()
        guard fileManager.fileExists(atPath: url.path) else {
            self.account = nil
            return
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.account = try decoder.decode(Account.self, from: data)
    }

    func current() -> Account? {
        account
    }

    private func fileURL() throws -> URL {
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Document directory not found"])
        }
        return directory.appendingPathComponent(fileName).appendingPathExtension("json")
    }
}
