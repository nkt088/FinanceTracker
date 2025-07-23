//
//  Account.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
// MARK: - Account Models
import Foundation

struct Account : Codable{
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}

//struct AccountBrief {
//    let id: Int
//    let name: String
//    let balance: Decimal
//    let currency: String
//}
struct AccountBrief: Decodable {
    let id: Int
    let name: String
    let balance: Decimal
    let currency: String

    init(id: Int, name: String, balance: Decimal, currency: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
    }

    enum CodingKeys: String, CodingKey {
        case id, name, balance, currency
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let balanceString = try container.decode(String.self, forKey: .balance)
        balance = Decimal(string: balanceString) ?? 1
        currency = try container.decode(String.self, forKey: .currency)
    }
}

//struct AccountState {
//    let id: Int
//    let name: String
//    let balance: Decimal
//    let currency: String
//}

enum AccountChangeType: String {
    case modification = "MODIFICATION"
    case creation = "CREATION"
}

//struct AccountCreateRequest {
//    let name: String
//    let balance: Decimal
//    let currency: String
//}

struct AccountUpdateRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
}

struct AccountResponse: Decodable {
    let id: Int
    let userId: Int
    let name: String
    let balance: String
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}
