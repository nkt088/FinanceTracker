//
//  TransactionsService.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

// MARK: - Domain Models

import Foundation

enum Direction: String {
    case income
    case outcome
}

struct Account {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}

struct AccountBrief {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
}

struct AccountState {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String
}

enum AccountChangeType: String {
    case modification = "MODIFICATION"
    case creation = "CREATION"
}

struct AccountHistory {
    let id: Int
    let accountId: Int
    let changeType: AccountChangeType
    let previousState: AccountState?
    let newState: AccountState
    let changeTimestamp: Date
    let createdAt: Date
}

struct AccountHistoryResponse {
    let accountId: Int
    let accountName: String
    let currency: String
    let currentBalance: Decimal
    let history: [AccountHistory]
}

struct AccountCreateRequest {
    let name: String
    let balance: Decimal
    let currency: String
}

struct AccountUpdateRequest {
    let name: String
    let balance: Decimal
    let currency: String
}

struct StatItem {
    let categoryId: Int
    let categoryName: String
    let emoji: Character
    let amount: Decimal
}

struct Category {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
}

struct Transaction {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}

struct TransactionRequest {
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
}

struct TransactionResponse {
    let id: Int
    let account: AccountBrief
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}
