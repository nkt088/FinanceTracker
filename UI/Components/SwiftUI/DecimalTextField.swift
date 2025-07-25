//
//  DecimalTextField.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
// При вставка: Hello234,bye,2, -> 234.2
import SwiftUI

struct DecimalTextField: View {
    let title: String
    @Binding var value: Decimal

    @State private var stringValue: String = ""

    var body: some View {
        TextField(title, text: $stringValue)
            .keyboardType(.decimalPad)
            .onChange(of: stringValue) {
                let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
                let filtered = stringValue.unicodeScalars
                    .filter { allowedCharacters.contains($0) }
                    .map { Character($0) }

                var cleaned = ""
                var separatorUsed = false

                for char in filtered {
                    if char == "." || char == "," {
                        if !separatorUsed {
                            cleaned.append(".")
                            separatorUsed = true
                        }
                    } else { cleaned.append(char) }
                }
                stringValue = cleaned
                if let decimal = Decimal(string: cleaned) {
                    value = decimal
                } else {
                    value = 0
                }
            }
            .onAppear {
                stringValue = NSDecimalNumber(decimal: value).stringValue
            }
            .onChange(of: value) {
                let newString = NSDecimalNumber(decimal: value).stringValue
                if newString != stringValue {
                    stringValue = newString
                }
            }
    }
}
