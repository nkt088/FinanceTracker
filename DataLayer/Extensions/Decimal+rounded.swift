//
//  Decimal.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import Foundation

extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}
