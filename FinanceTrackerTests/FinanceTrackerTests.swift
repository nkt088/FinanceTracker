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
        accountId: 1,
        categoryId: 2,
        amount: Decimal(string: "999.99")!,
        transactionDate: Date(),
        comment: "Test Transaction",
        createdAt: Date(),
        updatedAt: Date()
    )
    //JSON
    func testTransactionJSONSerializationAndParsing() throws {


        let json = transaction.jsonObject

        guard let parsed = Transaction.parse(jsonObject: json) else {
            XCTFail("Не удалось распарсить JSON")
            return
        }

        XCTAssertEqual(parsed.id, transaction.id)
        XCTAssertEqual(parsed.accountId, transaction.accountId)
        XCTAssertEqual(parsed.categoryId, transaction.categoryId)
        XCTAssertEqual(parsed.amount, transaction.amount)
        XCTAssertEqual(parsed.comment, transaction.comment)
        XCTAssertEqual(parsed.transactionDate.timeIntervalSince1970, transaction.transactionDate.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(parsed.createdAt.timeIntervalSince1970, transaction.createdAt.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(parsed.updatedAt.timeIntervalSince1970, transaction.updatedAt.timeIntervalSince1970, accuracy: 0.001)
    }

    func testTransactionParseFailsOnInvalidJSON() throws {
        let invalidJSON: Any = [
            "id": "not an int", // ошибка типа
            "accountId": 1,
            "categoryId": 2,
            "amount": "100",
            "transactionDate": Date().timeIntervalSince1970,
            "createdAt": Date().timeIntervalSince1970,
            "updatedAt": Date().timeIntervalSince1970
        ]

        let result = Transaction.parse(jsonObject: invalidJSON)
        XCTAssertNil(result, "Должно вернуться nil при некорректном JSON")
    }
    
    //CSV
    func testTransactionCSVSerializationAndParsing() throws {

        let csv = transaction.csvString
        print("CSV:", csv)

        guard let parsed = Transaction.parse(csvLine: csv) else {
            XCTFail("Не удалось распарсить CSV")
            return
        }

        XCTAssertEqual(parsed.id, transaction.id)
        XCTAssertEqual(parsed.accountId, transaction.accountId)
        XCTAssertEqual(parsed.categoryId, transaction.categoryId)
        XCTAssertEqual(parsed.amount, transaction.amount)
        XCTAssertEqual(parsed.comment, transaction.comment)
        XCTAssertEqual(parsed.transactionDate.timeIntervalSince1970, transaction.transactionDate.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(parsed.createdAt.timeIntervalSince1970, transaction.createdAt.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(parsed.updatedAt.timeIntervalSince1970, transaction.updatedAt.timeIntervalSince1970, accuracy: 1)
    }

    func testTransactionCSVParsingFailsOnInvalidFormat() {
        let brokenCSV = "1,1,2,INVALID_AMOUNT,2025-06-13T09:29:07Z,комментарий,2025-06-13T09:29:07Z,2025-06-13T09:29:07Z"
        let result = Transaction.parse(csvLine: brokenCSV)
        XCTAssertNil(result, "Парсинг должен вернуть nil при некорректной строке CSV")
    }
}
