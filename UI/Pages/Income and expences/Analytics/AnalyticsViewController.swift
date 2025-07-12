//
//  AnalyticsView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
import UIKit

final class AnalyticsViewController: UIViewController {

    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let periodView = PeriodSummaryView()
    private let tableContainer = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    private var endDate = Date()
    private var grouped: [(category: Category, amount: Decimal)] = []
    private var totalAmount: Decimal = 0

    private let direction: Direction
    
    var onClose: (() -> Void)?

    init(direction: Direction) {
        self.direction = direction
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = ""
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupViews()
        loadData()
    }

    private func setupViews() {
        backButton.setTitle("Назад", for: .normal)
        backButton.setTitleColor(.systemPurple, for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .systemPurple
        backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        backButton.semanticContentAttribute = .forceLeftToRight
        backButton.contentHorizontalAlignment = .leading
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Анализ"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        periodView.translatesAutoresizingMaskIntoConstraints = false
        periodView.onStartChanged = { [weak self] date in
            guard let self else { return }
            startDate = date
            if startDate > endDate {
                endDate = startDate
                periodView.updateEndDate(to: endDate)
            }
            loadData()
        }

        periodView.onEndChanged = { [weak self] date in
            guard let self else { return }
            endDate = date
            if endDate < startDate {
                startDate = endDate
                periodView.updateStartDate(to: startDate)
            }
            loadData()
        }

        tableContainer.translatesAutoresizingMaskIntoConstraints = false
        tableContainer.backgroundColor = .white
        tableContainer.layer.cornerRadius = 12
        tableContainer.layer.shadowColor = UIColor.black.cgColor
        tableContainer.layer.shadowOpacity = 0.05
        tableContainer.layer.shadowRadius = 4
        tableContainer.layer.shadowOffset = CGSize(width: 0, height: 2)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.dataSource = self

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(periodView)
        view.addSubview(tableContainer)
        tableContainer.addSubview(tableView)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            periodView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            periodView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            periodView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableContainer.topAnchor.constraint(equalTo: periodView.bottomAnchor, constant: 16),
            tableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor)
        ])
    }
    @objc private func didTapBack() {
        onClose?()
    }

    private func loadData() {
        Task {
            let start = Calendar.current.startOfDay(for: startDate)
            let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
                let transactions = try await TransactionsService.shared.transactions(from: start, to: end, accountId: 1)
                    .filter { $0.category.direction == direction }

                let byCategory = Dictionary(grouping: transactions, by: { $0.category })
                    .mapValues { $0.reduce(Decimal(0)) { $0 + $1.amount } }

                totalAmount = byCategory.values.reduce(0, +)
                grouped = byCategory
                    .map { (category: $0.key, amount: $0.value) }
                    .sorted { $0.amount > $1.amount }

                periodView.updateAmount(to: totalAmount)
                tableView.reloadData()
        }
    }
}

extension AnalyticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        grouped.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = grouped[indexPath.row]
        let raw = NSDecimalNumber(decimal: item.amount).doubleValue
        let total = NSDecimalNumber(decimal: totalAmount).doubleValue
        let percent = total == 0 ? 0 : (raw / total * 100).rounded(toPlaces: 1)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.configure(with: item.category, amount: item.amount, percent: Decimal(percent))
        return cell
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
