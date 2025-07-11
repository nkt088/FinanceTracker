//  WalletView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov

import SwiftUI

struct WalletView: View {
    @State private var isEditing = false
    @State private var showCurrencyPicker = false

    @State private var balance: Decimal = 0
    @State private var currency: String = "RUB"
    @State private var previousCurrency: String = "RUB"
    @State private var spoilerHidden = true

    @FocusState private var isBalanceFocused: Bool

    private let accountService = BankAccountsService.shared

    private let rates: [String: Decimal] = [
        "RUB": 1,
        "USD": 76.92,
        "EUR": 90.0
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Мой счет")
                            .font(.largeTitle.bold())

                        VStack(spacing: 12) {
                            WalletBalanceRow(
                                isEditing: isEditing,
                                balance: $balance,
                                currency: currency,
                                isFocused: $isBalanceFocused,
                                spoilerHidden: $spoilerHidden
                            )

                            WalletCurrencyRow(
                                isEditing: isEditing,
                                currency: currency,
                                onTap: { showCurrencyPicker = true }
                            )
                        }

                        Spacer()
                    }
                    .padding()
                }
                // * pull refresh
                .refreshable {
                    await load()
                }

                if showCurrencyPicker {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .background(Color(.systemGroupedBackground))
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Сохранить") {
                            Task {
                                await save()
                                isEditing = false
                            }
                        }
                    } else {
                        Button("Редактировать") {
                            isEditing = true
                            isBalanceFocused = true
                        }
                    }
                }
            }
            .task {
                await load()
            }
            .onAppear {
                    ShakeDetector.shared.onShake = {
                        spoilerHidden.toggle()
                    }
                }
            .onDisappear {
                    ShakeDetector.shared.onShake = nil
            }
            .confirmationDialog("Валюта", isPresented: $showCurrencyPicker, titleVisibility: .visible) {
                Button("Российский рубль ₽") { selectCurrency("RUB") }
                Button("Американский доллар $") { selectCurrency("USD") }
                Button("Евро €") { selectCurrency("EUR") }
                Button("Оставить", role: .cancel) {}
            }
        }
    }

    private func load() async {
        do {
            let acc = try await accountService.account()
            balance = acc.balance
            currency = acc.currency
            previousCurrency = acc.currency
        } catch {
            balance = 0
            currency = "RUB"
            previousCurrency = "RUB"
        }
    }

    private func save() async {
        let request = AccountUpdateRequest(
            name: "Основной счёт",
            balance: balance,
            currency: currency
        )
        _ = try? await accountService.updateAccount(request)
    }

    private func selectCurrency(_ new: String) {
        guard currency != new else { return }
        let newBalance = convert(balance: balance, from: currency, to: new)
        previousCurrency = currency
        currency = new
        balance = newBalance
    }

    private func convert(balance: Decimal, from old: String, to new: String) -> Decimal {
        guard let fromRate = rates[old], let toRate = rates[new] else { return balance }
        let rubles = balance * fromRate
        let newValue = rubles / toRate
        return newValue.rounded(scale: 2)
    }
}
