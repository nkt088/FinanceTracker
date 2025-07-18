//
//  TransactionsHistoryView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

import SwiftUI

struct TransactionsHistoryView: View {
    let direction: Direction
    @Environment(\.dismiss) private var dismiss
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var transactions: [Transaction] = []
    @State private var isLoading = false
    @State private var navigateToAnalytics = false
    @State private var editingTransaction: Transaction?
    @State private var sortMode: SortModeTransaction = .byDate

    @State private var categoriesMap: [Int: Category] = [:]

    private let service = TransactionsService.shared
    private let categoriesService = CategoriesService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack {
                    Text("Моя история")
                        .font(.largeTitle.bold())
                    Spacer()
                }

                VStack(spacing: 4) {
                    CustomDatePicker(title: "Начало", date: $startDate, components: .date)
                    Divider().padding(.vertical, 1)

                    CustomDatePicker(title: "Конец", date: $endDate, components: .date)
                    Divider().padding(.vertical, 1)

                    HStack {
                        Text("Сортировка")
                        Spacer()
                        Picker("", selection: $sortMode) {
                            ForEach(SortModeTransaction.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                    .padding(.vertical, 2)

                    Divider().padding(.vertical, 1)

                    HStack {
                        Text("Сумма")
                        Spacer()
                        Text(totalAmount.formatted(.currency(code: "RUB").locale(Locale(identifier: "ru_RU"))))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)

                Text("Операции")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(transactions) { tx in
                            Button {
                                editingTransaction = tx
                            } label: {
                                TransactionRowView(transaction: tx, category: categoriesMap[tx.categoryId])
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading)
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 16)
                }
            }
            .padding([.top, .horizontal])
        }
        .background(Color(.systemGroupedBackground))
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(isActive: $navigateToAnalytics) {
                    AnalyticsViewWrapper(direction: direction) {
                        navigateToAnalytics = false
                    }
                    .edgesIgnoringSafeArea(.top)
                } label: {
                    Image(systemName: "doc")
                }
            }
        }
        .fullScreenCover(item: $editingTransaction, onDismiss: reload) { tx in
            NavigationStack {
                TransactionUpdateView(direction: direction, mode: .edit(tx))
            }
        }
        .onChange(of: startDate) {
            if startDate > endDate {
                endDate = startDate
            }
            reload()
        }
        .onChange(of: endDate) {
            if endDate < startDate {
                startDate = endDate
            }
            reload()
        }
        .onChange(of: sortMode) {
            transactions = TransactionSorter.sort(transactions, by: sortMode)
        }
        .task {
            await load()
        }
    }

    private var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }

    private func reload() {
        Task {
            await load()
        }
    }

    private func load() async {
        isLoading = true
        let startOfStart = Calendar.current.startOfDay(for: startDate)
        let endOfEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!

        do {
            let all = try await service.transactions(from: startOfStart, to: endOfEnd, accountId: 104)
            //let all = try await service.transactions(from: startOfStart, to: endOfEnd, accountId: 1)
            let allCategories = try await categoriesService.categories(for: direction)
            let categoryIds = Set(allCategories.map(\.id))
            categoriesMap = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })

            let filtered = all.filter { categoryIds.contains($0.categoryId) }
            transactions = TransactionSorter.sort(filtered, by: sortMode)
        } catch {
            transactions = []
        }

        isLoading = false
    }
}
