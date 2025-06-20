//
//  DecimalTextField.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct DecimalTextField: View {
    let title: String
    @Binding var value: Decimal

    @State private var stringValue: String = ""

    var body: some View {
        TextField(title, text: $stringValue)
            .keyboardType(.decimalPad)
            .onChange(of: stringValue) {
                let clean = stringValue.replacingOccurrences(of: ",", with: ".")
                if let decimal = Decimal(string: clean) {
                    value = decimal
                }
            }
            .onAppear {
                stringValue = NSDecimalNumber(decimal: value).stringValue
            }
    }
}
