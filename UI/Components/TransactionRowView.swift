//
//  TransactionRowView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Text("\(transaction.category.emoji) \(transaction.category.name)")
            Spacer()
            Text(transaction.amount.formatted(.currency(code: "RUB")))
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
}
