//
//  CategoryRowView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct CategoryRowView: View {
    let category: Category

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accent.opacity(0.15))
                    .aspectRatio(1, contentMode: .fit)
                Text(String(category.emoji))
                    .font(.system(size: 16))
                    .padding(6)
            }
            .frame(width: 32, height: 32)

            Text(category.name)
                .font(.body)

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
}
