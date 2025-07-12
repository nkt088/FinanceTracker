//
//  CategoryCell.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import UIKit

final class CategoryCell: UITableViewCell {

    private let bubble = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let percentLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with category: Category, amount: Decimal, percent: Decimal) {
        emojiLabel.text = String(category.emoji)
        nameLabel.text = category.name

        let rounded = NSDecimalNumber(decimal: percent)
        percentLabel.text = "\(rounded)%"
        amountLabel.text = amount.formatted(.currency(code: "RUB").locale(Locale(identifier: "ru_RU")))
    }

    private func setup() {
        bubble.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        bubble.layer.cornerRadius = 16
        bubble.translatesAutoresizingMaskIntoConstraints = false

        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(emojiLabel)

        nameLabel.font = .systemFont(ofSize: 17)

        percentLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        percentLabel.textAlignment = .right

        amountLabel.font = .systemFont(ofSize: 13)
        amountLabel.textColor = .secondaryLabel
        amountLabel.textAlignment = .right

        let rightStack = UIStackView(arrangedSubviews: [percentLabel, amountLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 2

        let hStack = UIStackView(arrangedSubviews: [bubble, nameLabel, UIView(), rightStack])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(hStack)

        NSLayoutConstraint.activate([
            bubble.widthAnchor.constraint(equalToConstant: 32),
            bubble.heightAnchor.constraint(equalToConstant: 32),
            emojiLabel.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),

            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
