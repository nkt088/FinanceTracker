//
//  SortMode.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

enum SortModeCategory {
    case byDate
    case byAmount
}

struct CategorySorter {
    static func sort(transactions: [Transaction], mode: SortModeCategory) -> [(category: Category, amount: Decimal)] {
        let grouped = Dictionary(grouping: transactions, by: { $0.category })

        switch mode {
        case .byDate:
            return grouped
                .map { category, txs in
                    let latestDate = txs.map(\.transactionDate).max() ?? .distantPast
                    return (category: category, amount: txs.reduce(0, { $0 + $1.amount }), latest: latestDate)
                }
                .sorted { $0.latest > $1.latest }
                .map { ($0.category, $0.amount) }
        case .byAmount:
            return grouped
                .map { (category: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
                .sorted { $0.amount > $1.amount }
        }
    }
}

