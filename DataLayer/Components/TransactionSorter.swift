//
//  TransactionSorter.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

enum SortModeTransaction: String, CaseIterable, Identifiable {
    case byDate = "По дате"
    case byAmount = "По сумме"

    var id: Self { self }
}
struct TransactionSorter {
    
    static func sort(_ transactions: [Transaction], by mode: SortModeTransaction) -> [Transaction] {
        switch mode {
        case .byDate:
            return transactions.sorted { $0.transactionDate > $1.transactionDate }
        case .byAmount:
            return transactions.sorted { $0.amount > $1.amount }
        }
    }
}
