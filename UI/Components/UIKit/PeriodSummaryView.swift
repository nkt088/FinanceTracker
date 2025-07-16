//
//  PeriodSummaryView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import UIKit

final class PeriodSummaryView: UIView {

    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let startLabel = UILabel()
    private let endLabel = UILabel()
    private let amountTitleLabel = UILabel()
    private let amountValueLabel = UILabel()

    let sortControl = UISegmentedControl(items: ["По дате", "По сумме"])
    var onSortChanged: ((SortModeCategory) -> Void)?
    var onStartChanged: ((Date) -> Void)?
    var onEndChanged: ((Date) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateStartDate(to date: Date) {
        startDatePicker.date = date
    }

    func updateEndDate(to date: Date) {
        endDatePicker.date = date
    }

    func updateAmount(to amount: Decimal) {
        amountValueLabel.text = amount.formatted(.currency(code: "RUB").locale(Locale(identifier: "ru_RU")))
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)

        startLabel.text = "Начало"
        endLabel.text = "Конец"
        amountTitleLabel.text = "Сумма"

        [startLabel, endLabel, amountTitleLabel].forEach {
            $0.font = .systemFont(ofSize: 17)
            
        }

        amountValueLabel.font = .systemFont(ofSize: 17, weight: .medium)
        amountValueLabel.textAlignment = .right

        startDatePicker.datePickerMode = .date
        startDatePicker.locale = Locale(identifier: "ru_RU")
        startDatePicker.date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        startDatePicker.maximumDate = Date()
        endDatePicker.tintColor = .accent

        endDatePicker.datePickerMode = .date
        endDatePicker.locale = Locale(identifier: "ru_RU")
        endDatePicker.maximumDate = Date()
        endDatePicker.tintColor = .accent



        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)

        let row1 = labeledRow(label: startLabel, right: startDatePicker)
        let sep1 = separatorView()
        let row2 = labeledRow(label: endLabel, right: endDatePicker)
        let sep2 = separatorView()
        let row3 = labeledRow(label: amountTitleLabel, right: amountValueLabel)

        sortControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        let sortLabel = UILabel()
        sortLabel.text = "Сортировка"
        sortLabel.font = .systemFont(ofSize: 17)
        let sortRow = labeledRow(label: sortLabel, right: sortControl)
        sortRow.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        sortRow.isLayoutMarginsRelativeArrangement = true
        let stack = UIStackView(arrangedSubviews: [row1, sep1, row2, sep2, sortRow, separatorView(), row3])
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func labeledRow(label: UILabel, right: UIView) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [label, right])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        row.alignment = .center
        row.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return row
    }

    private func separatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .separator
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }
    
    func setSortMode(_ mode: SortModeCategory) {
        sortControl.selectedSegmentIndex = mode == .byDate ? 0 : 1
    }
    
    @objc private func sortChanged() {
        let mode: SortModeCategory = sortControl.selectedSegmentIndex == 0 ? .byDate : .byAmount
        onSortChanged?(mode)
    }
    
    @objc private func startDateChanged() {
        onStartChanged?(startDatePicker.date)
    }

    @objc private func endDateChanged() {
        onEndChanged?(endDatePicker.date)
    }
}
