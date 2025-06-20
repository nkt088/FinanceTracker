/*
  FinanceTrackerTests.swift
  FinanceTrackerTests

  Created by MakhovN @nktmahov

 Test Suite 'FinanceTrackerTests' started at 2025-06-13 17:36:50.760.
 Test Case '-[FinanceTrackerTests.FinanceTrackerTests testTransactionCSVParsingFailsOnInvalidFormat]' started.
 Test Case '-[FinanceTrackerTests.FinanceTrackerTests testTransactionCSVParsingFailsOnInvalidFormat]' passed (0.002 seconds).
 Test Case '-[FinanceTrackerTests.FinanceTrackerTests testTransactionCSVSerializationAndParsing]' started.
 CSV: 42,1,2,999.99,2025-06-13T14:36:50Z,"Test Transaction",2025-06-13T14:36:50Z,2025-06-13T14:36:50Z
 Test Case '-[FinanceTrackerTests.FinanceTrackerTests testTransactionCSVSerializationAndParsing]' passed (0.004 seconds).
 Test Case '-[FinanceTrackerTests.FinanceTrackerTests testTransactionJSONSerializationAndParsing]' started.
 Test Case '-[FinanceTrackerTests.FinanceTrackerTests testTransactionJSONSerializationAndParsing]' passed (0.001 seconds).
 Test Case '-[FinanceTrackerTests.FinanceTrackerTests testTransactionParseFailsOnInvalidJSON]' started.
 Test Case '-[FinanceTrackerTests.FinanceTrackerTests testTransactionParseFailsOnInvalidJSON]' passed (0.001 seconds).
 Test Suite 'FinanceTrackerTests' passed at 2025-06-13 17:36:50.769.
      Executed 4 tests, with 0 failures (0 unexpected) in 0.008 (0.009) seconds
 */

// MARK: - Tests JSON, CSV Transaction

import XCTest

@testable import FinanceTracker

final class FinanceTrackerTests: XCTestCase {
    private let transaction = Transaction(
        id: 42,
        account: AccountBrief(id: 1, name: "Основной", balance: 1000, currency: "RUB"),
        category: Category(id: 2, name: "Зарплата", emoji: "💰", direction: .income),
        amount: Decimal(string: "999.99")!,
        transactionDate: Date(),
        comment: "Test Transaction",
        createdAt: Date(),
        updatedAt: Date()
    )

    func testTransactionJSONSerializationAndParsing() throws {
        let json = transaction.jsonObject

        guard let parsed = Transaction.parse(jsonObject: json) else {
            XCTFail("Не удалось распарсить JSON")
            return
        }

        XCTAssertEqual(parsed.id, transaction.id)
        XCTAssertEqual(parsed.account.id, transaction.account.id)
        XCTAssertEqual(parsed.category.id, transaction.category.id)
        XCTAssertEqual(parsed.amount, transaction.amount)
        XCTAssertEqual(parsed.comment, transaction.comment)
        XCTAssertEqual(parsed.transactionDate.timeIntervalSince1970, transaction.transactionDate.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(parsed.createdAt.timeIntervalSince1970, transaction.createdAt.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(parsed.updatedAt.timeIntervalSince1970, transaction.updatedAt.timeIntervalSince1970, accuracy: 0.001)
    }

    func testTransactionParseFailsOnInvalidJSON() throws {
        let invalidJSON: Any = [
            "id": "not an int",
            "account": ["id": 1, "name": "Основной", "balance": "1000.00", "currency": "RUB"],
            "category": ["id": 2, "name": "Зарплата", "emoji": "💰", "isIncome": true],
            "amount": "100",
            "transactionDate": Date().timeIntervalSince1970,
            "createdAt": Date().timeIntervalSince1970,
            "updatedAt": Date().timeIntervalSince1970
        ]

        let result = Transaction.parse(jsonObject: invalidJSON)
        XCTAssertNil(result, "Должно вернуться nil при некорректном JSON")
    }
    func testPrintDocumentsDirectoryPathAndSaveJSON() async throws {
        let fileManager = FileManager.default
        let fileName = "test_transaction.json"

        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            XCTFail("Не удалось получить Documents директорию")
            return
        }

        let fileURL = documentsURL.appendingPathComponent(fileName)
        print("Путь к файлу:", fileURL.path)

        // Пример сериализации и сохранения
        let json = transaction.jsonObject
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try data.write(to: fileURL, options: .atomic)
    }

//    func testTransactionCSVSerializationOnly() throws {
//        let csv = transaction.csvString
//        print("CSV:", csv)
//
//        XCTAssertTrue(csv.contains(transaction.account.name))
//        XCTAssertTrue(csv.contains(transaction.category.name))
//        XCTAssertTrue(csv.contains("999.99"))
//    }
//
//    func testTransactionCSVParsingFailsOnInvalidFormat() {
//        let brokenCSV = "1,Основной,Зарплата,INVALID_AMOUNT,2025-06-13T09:29:07Z,комментарий,2025-06-13T09:29:07Z,2025-06-13T09:29:07Z"
//        // Нет парсера, поэтому должно быть nil всегда
//        let result = Transaction.parse(csvLine: brokenCSV)
//        XCTAssertNil(result)
//    }
}
