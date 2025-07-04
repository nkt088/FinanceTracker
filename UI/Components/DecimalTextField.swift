//
//  DecimalTextField.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
<<<<<<< Updated upstream

=======
// При вставка: Hello234,bye,2, -> 234.2
>>>>>>> Stashed changes
import SwiftUI

struct DecimalTextField: View {
    let title: String
    @Binding var value: Decimal

    @State private var stringValue: String = ""

    var body: some View {
        TextField(title, text: $stringValue)
            .keyboardType(.decimalPad)
            .onChange(of: stringValue) {
<<<<<<< Updated upstream
                let clean = stringValue.replacingOccurrences(of: ",", with: ".")
                if let decimal = Decimal(string: clean) {
=======
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
>>>>>>> Stashed changes
                    value = decimal
                }
            }
            .onAppear {
                stringValue = NSDecimalNumber(decimal: value).stringValue
            }
    }
}
