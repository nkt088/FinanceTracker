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
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .aspectRatio(1, contentMode: .fit)
                Text(String(transaction.category.emoji))
                    .font(.system(size: 16))
                    .padding(6)
            }
            .frame(width: 32, height: 32)

            Text(transaction.category.name)
                .font(.body)

            Spacer()

            Text(transaction.amount.formatted(
                .currency(code: "RUB").locale(Locale(identifier: "ru_RU"))
            ))
            .font(.body)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
}
