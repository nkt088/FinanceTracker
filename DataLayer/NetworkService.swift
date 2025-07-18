//
//  NetworkClient.swift
//  FinanceTracker
//
//  Created by Nikita Makhov on 18.07.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case encodingError
    case serverError(statusCode: Int)
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    private let baseURL = "https://shmr-finance.ru/api/v1/"
    private let token = "MAg74XaauNcKQB2rvFSFdN30"
    
    private var isoDateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }
    
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // ЛОГ ЗАПРОСА
        print("REQUEST: \(method) \(request.url!.absoluteString)")
        if let body = body, let json = String(data: body, encoding: .utf8) {
            print("BODY: \(json)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        // ЛОГ ОТВЕТА
        if let httpResponse = response as? HTTPURLResponse {
            print("RESPONSE: \(httpResponse.statusCode)")
        }
        if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: responseJSON, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("RESPONSE BODY:\n\(prettyString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)

                // ISO8601 без микросекунд
                let iso8601 = ISO8601DateFormatter()
                iso8601.formatOptions = [.withInternetDateTime]
                if let date = iso8601.date(from: dateStr) {
                    return date
                }

                // ISO8601 с микросекундами
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                if let date = formatter.date(from: dateStr) {
                    return date
                }

                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateStr)")
            }
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchAllCategories() async throws -> [CategoryResponse] {
        try await request(path: "categories")
    }
    
    func fetchCategories(isIncome: Bool) async throws -> [CategoryResponse] {
        try await request(path: "categories/type/\(isIncome)")
    }
    func deleteTransaction(id: Int) async throws {
        _ = try await request(path: "transactions/\(id)", method: "DELETE") as EmptyResponse
    }
//    func createTransaction(_ requestModel: TransactionRequest) async throws {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        guard let data = try? encoder.encode(requestModel) else {
//            throw NetworkError.encodingError
//        }
//        _ = try await request(path: "transactions", method: "POST", body: data) as EmptyResponse
//    }
    
    
    func createTransaction(_ requestModel: TransactionRequest) async throws -> Transaction {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(requestModel) else {
            throw NetworkError.encodingError
        }
        return try await request(path: "transactions", method: "POST", body: data)
    }
    func fetchTransactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [TransactionResponse] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)

        let path = "transactions/account/\(accountId)/period?accountId=\(accountId)&startDate=\(start)&endDate=\(end)"
        return try await request(path: path)
    }
    func updateTransaction(id: Int, _ requestModel: TransactionRequest) async throws -> Transaction {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(requestModel) else {
            throw NetworkError.encodingError
        }
        return try await request(path: "transactions/\(id)", method: "PUT", body: data)
    }
}

extension Transaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        accountId = try container.decode(Int.self, forKey: .accountId)
        categoryId = try container.decode(Int.self, forKey: .categoryId)

        let amountString = try container.decode(String.self, forKey: .amount)
        guard let amountDecimal = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(forKey: .amount, in: container, debugDescription: "Invalid decimal string")
        }
        amount = amountDecimal

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        guard let parsedTransactionDate = dateFormatter.date(from: try container.decode(String.self, forKey: .transactionDate)) else {
            throw DecodingError.dataCorruptedError(forKey: .transactionDate, in: container, debugDescription: "Invalid transactionDate")
        }
        transactionDate = parsedTransactionDate

        // createdAt и updatedAt могут отсутствовать в ответе на создание — обрабатываем безопасно
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
           let parsedCreatedAt = dateFormatter.date(from: createdAtString) {
            createdAt = parsedCreatedAt
        } else {
            createdAt = transactionDate // или Date()
        }

        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt),
           let parsedUpdatedAt = dateFormatter.date(from: updatedAtString) {
            updatedAt = parsedUpdatedAt
        } else {
            updatedAt = transactionDate // или Date()
        }

        comment = try container.decodeIfPresent(String.self, forKey: .comment)
    }
}

