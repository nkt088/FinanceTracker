//
//  TransactionRowView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let category: Category?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accent.opacity(0.15))
                    .aspectRatio(1, contentMode: .fit)

                Text(String(category?.emoji ?? "•"))
                    .font(.system(size: 16))
                    .padding(6)
            }
            .frame(width: 32, height: 32)

            Text(category?.name ?? "Категория")
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
