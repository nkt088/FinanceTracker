// LottieLoader.swift
import Foundation
import Lottie
import UIKit

public class LottieLoader {
    public static func makeView(animationName: String, completion: @escaping () -> Void) -> UIView {
        let container = UIView()
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play { finished in
            if finished {
                completion()
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
}