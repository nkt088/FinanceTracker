//
//  CustomDataPicker.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct CustomDatePicker: View {
    let title: String
    @Binding var date: Date
    let components: DatePickerComponents

    var body: some View {
        DatePicker(title, selection: $date, displayedComponents: components)
            .environment(\.locale, Locale(identifier: "ru_RU"))
            .tint(.accent)
    }
}
