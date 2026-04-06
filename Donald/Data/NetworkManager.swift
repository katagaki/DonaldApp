//
//  NetworkManager.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import Foundation

final class NetworkManager {

    static let shared = NetworkManager()

    private let baseURL = "https://katagaki.github.io/DonaldWeb/data"

    private init() {}

    func fetchSourceKeys() async throws -> [String] {
        let url = URL(string: "\(baseURL)/sources.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([String].self, from: data)
    }

    func fetchDataSource(key: String) async throws -> DataSource {
        let url = URL(string: "\(baseURL)/\(key).json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(DataSource.self, from: data)
        return decoded.withKey(key)
    }
}
