//
//  PieChartView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
import UIKit

public struct PieChartEntity {
    public let value: Decimal
    public let label: String

    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

public final class PieChartView: UIView {

    public var entities: [PieChartEntity] = [] {
        didSet { setNeedsDisplay() }
    }

    private let colors: [UIColor] = [
        UIColor.systemGreen,
        UIColor.systemYellow,
        UIColor.systemBlue,
        UIColor.systemOrange,
        UIColor.systemPurple,
        UIColor.systemGray
    ]

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !entities.isEmpty else { return }

        let total = entities.map { $0.value }.reduce(0, +)
        guard total > 0 else { return }

        let sorted = entities.sorted { $0.value > $1.value }
        let top5 = sorted.prefix(5)
        let othersValue = sorted.dropFirst(5).map { $0.value }.reduce(0, +)

        var displayEntities = Array(top5)
        if othersValue > 0 {
            displayEntities.append(PieChartEntity(value: othersValue, label: "Остальные"))
        }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let lineWidth: CGFloat = 20
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        var startAngle: CGFloat = -.pi / 2

        for (i, entity) in displayEntities.enumerated() {
            let percent = CGFloat((entity.value / total as NSDecimalNumber).doubleValue)
            let endAngle = startAngle + percent * 2 * .pi
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.lineWidth = lineWidth
            colors[i % colors.count].setStroke()
            path.stroke()
            startAngle = endAngle
        }

        for (i, entity) in displayEntities.enumerated() {
            let percent = CGFloat((entity.value / total as NSDecimalNumber).doubleValue)
            let percentText = "\(Int(round(percent * 100)))% \(entity.label)"
            let color = colors[i % colors.count]
            let y = center.y - 28 + CGFloat(i * 18)

            let dotRect = CGRect(x: center.x - 50, y: y + 2, width: 8, height: 8)
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: dotRect)

            let textRect = CGRect(x: dotRect.maxX + 6, y: y, width: 120, height: 14)
            let text = NSAttributedString(string: percentText, attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.label
            ])
            text.draw(in: textRect)
        }
    }
}
