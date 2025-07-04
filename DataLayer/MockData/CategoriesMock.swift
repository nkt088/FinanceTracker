//
//  CategoriesMock.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

final class MockCategoriesService {
    func categories() async throws -> [Category] {
        [
            //Расходы
            Category(id: 1, name: "Аренда квартиры", emoji: "🏠", direction: .outcome),
            Category(id: 2, name: "Одежда", emoji: "👚", direction: .outcome),
            Category(id: 3, name: "На собачку", emoji: "🐶", direction: .outcome),
            Category(id: 4, name: "Ремонт квартиры", emoji: "🛠", direction: .outcome),
            Category(id: 5, name: "Продукты", emoji: "🍏", direction: .outcome),
            Category(id: 6, name: "Спортзал", emoji: "🏋️", direction: .outcome),
            Category(id: 7, name: "Медицина", emoji: "💉", direction: .outcome),
            Category(id: 8, name: "Aптека", emoji: "💊", direction: .outcome),
            Category(id: 9, name: "Машина", emoji: "🚗", direction: .outcome),
            
            // Доходы
            Category(id: 10, name: "Работа", emoji: "💼", direction: .income),
            Category(id: 11, name: "Подработка", emoji: "🛠️", direction: .income),
            Category(id: 12, name: "Иные доходы", emoji: "💸", direction: .income)
        ]
    }
    func categories(for direction: Direction) async throws -> [Category] {
        try await categories().filter { $0.direction == direction }
    }
}
