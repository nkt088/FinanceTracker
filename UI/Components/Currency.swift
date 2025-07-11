//
//  Currency.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

extension String {
    var currencySymbol: String {
        switch self.uppercased() {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default: return self
        }
    }
}
