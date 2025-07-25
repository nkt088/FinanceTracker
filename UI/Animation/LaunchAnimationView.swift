//
//  LaunchAnimationView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
import SwiftUI
import AnimationKit

struct LaunchAnimationView: UIViewRepresentable {
    let onComplete: () -> Void

    func makeUIView(context: Context) -> UIView {
        LottieLoader.makeView(animationName: "loading", completion: onComplete)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
