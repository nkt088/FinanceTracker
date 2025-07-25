//
//  LaunchAnimationView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
import SwiftUI
import AnimationKit
import Lottie 

struct LaunchAnimationView: UIViewRepresentable {
    let onComplete: () -> Void

    func makeUIView(context: Context) -> UIView {
        let container = UIView()

        let animationView = LottieAnimationView(name: "loading")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce

        animationView.play { finished in
            if finished {
                DispatchQueue.main.async {
                    onComplete()
                }
            }
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
