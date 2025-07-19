//
//  SortMode.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

//enum SortModeCategory {
//    case byDate
//    case byAmount
//}

//struct CategorySorter {
//    static func sort(grouped: [(category: Category, amount: Decimal)], mode: SortModeCategory) -> [(category: Category, amount: Decimal)] {
//        switch mode {
//        case .byAmount:
//            return grouped.sorted { $0.amount > $1.amount }
//        case .byDate:
//            return grouped
//        }
//    }
//}
enum SortModeCategory {
    case byDate
    case byAmount
}

struct CategorySorter {
    static func sort(grouped: [(category: Category, transactions: [Transaction])], mode: SortModeCategory) -> [(category: Category, amount: Decimal)] {
        switch mode {
        case .byAmount:
            return grouped
                .map { ($0.category, $0.transactions.reduce(0) { $0 + $1.amount }) }
                .sorted { $0.1 > $1.1 }

        case .byDate:
            return grouped
                .sorted {
                    let date0 = $0.transactions.map(\.transactionDate).max() ?? .distantPast
                    let date1 = $1.transactions.map(\.transactionDate).max() ?? .distantPast
                    return date0 > date1
                }
                .map { ($0.category, $0.transactions.reduce(0) { $0 + $1.amount }) }
        }
    }
}
