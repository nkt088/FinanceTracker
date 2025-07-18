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
    
    private func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        guard 200..<300 ~= httpResponse.statusCode else { throw NetworkError.serverError(statusCode: httpResponse.statusCode) }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchAllCategories() async throws -> [CategoryResponse] {
        try await request(path: "categories")
    }
    
    func fetchCategories(isIncome: Bool) async throws -> [CategoryResponse] {
        try await request(path: "category/type/\(isIncome)")
    }
    
    func createTransaction(_ requestModel: TransactionRequest) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(requestModel) else {
            throw NetworkError.encodingError
        }
        _ = try await request(path: "transactions", method: "POST", body: data) as EmptyResponse
    }
}
