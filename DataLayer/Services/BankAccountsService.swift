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
        // Если в памяти нет актуальных данных пробуем подгрузить
        if cache.current() == nil {
            try? cache.load()
            if let loaded = cache.current() {
                self.account = loaded
            } else if NetworkMonitor.shared.isConnected {
                let remote = try await NetworkService.shared.fetchAccount()
                let account = Account(
                    id: remote.id,
                    userId: remote.userId,
                    name: remote.name,
                    balance: Decimal(string: remote.balance) ?? 0,
                    currency: remote.currency,
                    createdAt: remote.createdAt,
                    updatedAt: remote.updatedAt
                )
                try? cache.save(account)
                self.account = account
            } else {
                // Нет сети, нет файла — создаём дефолтный локальный аккаунт
                let account = Account(
                    id: -1,
                    userId: -1,
                    name: "Основной счёт",
                    balance: 0,
                    currency: "RUB",
                    createdAt: Date(),
                    updatedAt: Date()
                )
                try? cache.save(account)
                self.account = account
            }
        }

        return account
    }

    func updateAccount(_ update: AccountUpdateRequest) async throws -> Account {
        isManualBalanceSet = true
        let balanceDecimal = Decimal(string: update.balance) ?? 0

        account = Account(
            id: account.id,
            userId: account.userId,
            name: update.name,
            balance: balanceDecimal,
            currency: update.currency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        try? cache.save(account)
        return account
    }

    func applyTransaction(_ tx: Transaction) {
        guard !isManualBalanceSet else { return }
        guard let category = CategoriesService.shared.category(by: tx.categoryId) else {
            return
        }
        let newBalance: Decimal
        switch category.direction {
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
    func saveLoadedAccount(_ response: AccountResponse) throws {
        let account = Account(
            id: response.id,
            userId: response.userId,
            name: response.name,
            balance: Decimal(string: response.balance) ?? 0,
            currency: response.currency,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt
        )
        try? cache.save(account)
    }
}
