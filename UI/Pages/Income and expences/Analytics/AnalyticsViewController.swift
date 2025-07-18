//
//  AnalyticsView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//
import UIKit

final class AnalyticsViewController: UIViewController {

    private let titleLabel = UILabel()
    private let periodView = PeriodSummaryView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    private var endDate = Date()
    private var grouped: [(category: Category, amount: Decimal)] = []
    private var totalAmount: Decimal = 0
    
    private var sortMode: SortModeCategory = .byDate

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
        navigationItem.leftBarButtonItem?.tintColor = .systemPurple
        setupViews()
        loadData()
    }

    private func setupViews() {

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
        periodView.onSortChanged = { [weak self] mode in
            guard let self else { return }
            sortMode = mode
            loadData()
        }

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.dataSource = self

        view.addSubview(titleLabel)
        view.addSubview(periodView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            periodView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            periodView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            periodView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: periodView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func didTapBack() {
        onClose?()
    }

    private func loadData() {
        Task {
            let start = Calendar.current.startOfDay(for: startDate)
            let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!

            let allTransactions = try await TransactionsService.shared.transactions(from: start, to: end, accountId: 1)
            let allCategories = try await CategoriesService.shared.categories(for: direction)
            let categoryMap = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
            let validCategoryIds = Set(categoryMap.keys)

            let filtered = allTransactions.filter { validCategoryIds.contains($0.categoryId) }

            let groupedDict = Dictionary(grouping: filtered, by: { $0.categoryId })

            var result: [(Category, Decimal)] = []
            for (categoryId, transactions) in groupedDict {
                guard let category = categoryMap[categoryId] else { continue }
                let sum = transactions.reduce(0) { $0 + $1.amount }
                result.append((category, sum))
            }

            self.grouped = CategorySorter.sort(grouped: result, mode: sortMode)
            self.totalAmount = result.map(\.1).reduce(0, +)

            periodView.updateAmount(to: totalAmount)
            periodView.setSortMode(sortMode)
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
