//
//  WalletBalanceRow.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct WalletBalanceRow: View {
    let isEditing: Bool
    @Binding var balance: Decimal
    let currency: String
    @FocusState.Binding var isFocused: Bool
    @Binding var spoilerHidden: Bool
    
    var body: some View {
        HStack {
            Text("💰 Баланс")
            Spacer()
            if isEditing {
                HStack(spacing: 4) {
                    DecimalTextField(title: "", value: $balance)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                        .focused($isFocused)
                    Text(currency.currencySymbol)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack(spacing: 4) {
                    Text(balance.formatted(.number.grouping(.automatic)))
                        .foregroundColor(.secondary)
                        .spoiler(isOn: $spoilerHidden)
                    Text(currency.currencySymbol)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(isEditing ? Color.white : Color.accent)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
