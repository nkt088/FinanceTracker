//
//  BankAccountsMock.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation


final class MockBankAccountsService {
    private var account = Account(
        id: 1,
        userId: 1,
        name: "Основной счёт",
        balance: Decimal(string: "1000.00")!,
        currency: "RUB",
        createdAt: Date(),
        updatedAt: Date()
    )

    func account() async throws -> Account {
        account
    }
//можно добавить проверку что не все поля заполнены guard return nil Account ?
    func updateAccount(_ update: AccountUpdateRequest) async throws -> Account {
        account = Account(
            id: account.id,
            userId: account.userId,
            name: update.name,
            balance: update.balance,
            currency: update.currency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        return account
    }
}
