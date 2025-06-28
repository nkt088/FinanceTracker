//
//  DecimalTextField.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
// если есть буквы, вставка не происходит,
// если разделителей насколько то остается только первый
// если числа то вставка коректна
// иначе 0
import SwiftUI

struct DecimalTextField: View {
    let title: String
    @Binding var value: Decimal

    @State private var stringValue: String = ""

    var body: some View {
        TextField(title, text: $stringValue)
            .keyboardType(.decimalPad)
            .onChange(of: stringValue) {
                if stringValue.rangeOfCharacter(from: .letters) != nil {
                    // Есть буквы — сброс
                    value = 0
                    stringValue = ""
                    return
                }
                let separators = [",", "."].compactMap { sep in
                    stringValue.firstIndex(of: Character(sep)).map { (sep, $0) }
                }.sorted { $0.1 < $1.1 }

                let decimalSeparator = separators.first?.0 ?? "."
                var cleaned = stringValue.filter { "0123456789., ".contains($0) }

                // Удалим все разделители, кроме первого
                var seenSeparator = false
                cleaned = cleaned.reduce(into: "") { result, char in
                    if char == "." || char == "," {
                        if !seenSeparator && String(char) == decimalSeparator {
                            result.append(".") // нормализуем в точку
                            seenSeparator = true
                        }
                    } else {
                        result.append(char)
                    }
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
    }
}
