//
//  RootView.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI

struct RootView: View {
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    var body: some View {
        TabView {
            NavigationStack {
                TransactionsListView(direction: .outcome)
            }
            .tint(.purple)
            .tabItem {
                Image(systemName: "chart.line.downtrend.xyaxis")
                Text("Расходы")
            }

            NavigationStack {
                TransactionsListView(direction: .income)
            }
            .tint(.purple)
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Доходы")
            }

            NavigationStack {
                WalletView()
            }
            .tint(.purple)
            .tabItem {
                Image(systemName: "chart.bar.yaxis")
                Text("Счёт")
            }

            PlaceholderView(title: "Статьи")
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Статьи")
                }

            PlaceholderView(title: "Настройки")
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Настройки")
                }
        }
        .accentColor(.accent)
    }
}

private struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack {
            Spacer()
            Text(title)
                .font(.title2.bold())
            Spacer()
        }
    }
}

#Preview {
    RootView()
}
