//
//  AddTransactionButton.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct AddTransactionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title)
                .padding()
                .background(Circle().fill(Color.accentColor))
                .foregroundColor(.white)
        }
        .padding()
    }
}
