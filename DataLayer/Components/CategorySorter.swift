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
    static func sort(grouped: [(category: Category, amount: Decimal)], mode: SortModeCategory) -> [(category: Category, amount: Decimal)] {
        switch mode {
        case .byAmount:
            return grouped.sorted { $0.amount > $1.amount }
        case .byDate:
            return grouped
        }
    }
}
