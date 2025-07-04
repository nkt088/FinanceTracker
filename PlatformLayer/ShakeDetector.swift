//
//  ShakeDetector.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import UIKit

final class ShakeDetector {
    static let shared = ShakeDetector()
    var onShake: (() -> Void)?

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShake),
            name: .deviceDidShake,
            object: nil
        )
    }

    @objc private func handleShake() {
        onShake?()
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        NotificationCenter.default.post(name: .deviceDidShake, object: nil)
    }
}

extension Notification.Name {
    static let deviceDidShake = Notification.Name("deviceDidShake")
}
