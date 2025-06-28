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
                Text(symbol(for: currency))
                    .foregroundColor(.secondary)
                if isEditing {
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isEditing)
    }

    private func symbol(for code: String) -> String {
        switch code.uppercased() {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default: return code
        }
    }
}
