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
    @FocusState.Binding var isFocused: Bool
    @Binding var spoilerHidden: Bool

    var body: some View {
        HStack {
            Label("Баланс", systemImage: "banknote")
            Spacer()
            if isEditing {
                DecimalTextField(title: "", value: $balance)
                    .frame(width: 120)
                    .multilineTextAlignment(.trailing)
                    .focused($isFocused)
            } else {
                Text(balance.formatted(.number.grouping(.automatic)))
                    .foregroundColor(.secondary)
                    .spoiler(isOn: $spoilerHidden)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
