//
//  DeleteTransactionButton.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
import SwiftUI

struct DeleteTransactionButton: View {
    let transaction: Transaction
    let direction: Direction
    let onDelete: () -> Void

    var body: some View {
        Button("Удалить \(direction == .income ? "доход" : "расход")", role: .destructive) {
            Task {
                try? await MockTransactionsService.shared.delete(id: transaction.id)
                onDelete()
            }
        }
    }
}
