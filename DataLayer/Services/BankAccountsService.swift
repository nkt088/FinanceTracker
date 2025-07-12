//
//  BankAccountsService.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

// MARK: - Bank Account Service

import Foundation

final class BankAccountsService {
    static let shared = BankAccountsService()
    private init() {
        loadFromFile()
    }

    private let cache = AccountFileCache.shared
    private var isManualBalanceSet = false

    private var account = Account(
        id: 1,
        userId: 1,
        name: "Основной счёт",
        balance: Decimal(string: "0.00")!,
        currency: "RUB",
        createdAt: Date(),
        updatedAt: Date()
    )

    func account() async throws -> Account {
        return account
    }

    func updateAccount(_ update: AccountUpdateRequest) async throws -> Account {
        isManualBalanceSet = true
        account = Account(
            id: account.id,
            userId: account.userId,
            name: update.name,
            balance: update.balance,
            currency: update.currency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        try? cache.save(account)
        return account
    }

    func applyTransaction(_ tx: Transaction) {
        guard !isManualBalanceSet else { return }

        let newBalance: Decimal
        switch tx.category.direction {
        case .income:
            newBalance = account.balance + tx.amount
        case .outcome:
            newBalance = account.balance - tx.amount
        }

        account = Account(
            id: account.id,
            userId: account.userId,
            name: account.name,
            balance: newBalance,
            currency: account.currency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        try? cache.save(account)
    }

    func brief() -> AccountBrief {
        AccountBrief(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency
        )
    }

    private func loadFromFile() {
        try? cache.load()
        if let loaded = cache.current() {
            self.account = loaded
        }
    }
}
