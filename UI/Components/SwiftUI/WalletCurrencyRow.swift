//
//  WalletCurrencyRow.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct WalletCurrencyRow: View {
    let isEditing: Bool
    let currency: String
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            if isEditing { onTap() }
        }) {
            HStack {
                Text("Валюта")
                    .foregroundColor(.primary)
                Spacer()
                Text(currency.currencySymbol)
                    .foregroundColor(.secondary)
                if isEditing {
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(isEditing ? Color.white : Color.accent.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isEditing)
    }
}
