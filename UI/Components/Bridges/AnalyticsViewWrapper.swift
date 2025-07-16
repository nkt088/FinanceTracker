//
//  AnalyticsViewWrapper.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct AnalyticsViewWrapper: UIViewControllerRepresentable {
    let direction: Direction
    var onClose: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = AnalyticsViewController(direction: direction)
        vc.onClose = onClose
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
