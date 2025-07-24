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

    private(set) var accountId: Int?

    func setAccountId(_ id: Int) {
        self.accountId = id
    }
}
