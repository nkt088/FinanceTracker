//
//  Account.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
// MARK: - Account Models
import Foundation

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
