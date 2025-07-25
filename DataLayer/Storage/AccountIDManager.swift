//
//  AccountIDManager.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

final class AccountManager {
    static let shared = AccountManager()
    private init() {}

    private let defaults = UserDefaults.standard

    var accountId: Int? {
        do {
            try AccountFileCache.shared.load()
            let id = AccountFileCache.shared.current()?.id
            if let id = id {
                defaults.set(id, forKey: "account_id") // сохраняем в UserDefaults
            }
            return id
        } catch {
            print("Ошибка загрузки аккаунта из файла: \(error)")
            return nil
        }
    }

    var cachedAccountId: Int? {
        defaults.integer(forKey: "account_id") == 0 ? nil : defaults.integer(forKey: "account_id")
    }
}
