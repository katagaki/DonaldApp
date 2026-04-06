//
//  DatasetManager.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import Foundation
import SwiftUI

@Observable
final class DatasetManager {

    var availableKeys: [String] = []
    var loadedKeys: Set<String> = []
    var downloadingKeys: Set<String> = []
    var allItems: [FoodItem] = []
    var sourceLabels: [String: String] = [:]
    var isLoadingKeys = false
    var error: String?

    init() {
        refreshLoadedKeys()
        reloadItems()
    }

    // MARK: - Remote Sources

    func fetchAvailableDatasets() async {
        isLoadingKeys = true
        error = nil
        do {
            let keys = try await NetworkManager.shared.fetchSourceKeys()
            await MainActor.run {
                self.availableKeys = keys
                self.isLoadingKeys = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoadingKeys = false
            }
        }
    }

    func downloadDataset(key: String) async {
        await MainActor.run { downloadingKeys.insert(key) }
        do {
            let source = try await NetworkManager.shared.fetchDataSource(key: key)
            try DatabaseManager.shared.importDataSource(source)
            await MainActor.run {
                self.downloadingKeys.remove(key)
                self.refreshLoadedKeys()
                self.reloadItems()
            }
        } catch {
            await MainActor.run {
                self.downloadingKeys.remove(key)
                self.error = error.localizedDescription
            }
        }
    }

    func deleteDataset(key: String) {
        do {
            try DatabaseManager.shared.deleteSource(key: key)
            refreshLoadedKeys()
            reloadItems()
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - User Import

    func importJSON(from url: URL) throws {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(DataSource.self, from: data)
        let key = url.deletingPathExtension().lastPathComponent
        let source = decoded.withKey(key)
        try DatabaseManager.shared.importDataSource(source)
        refreshLoadedKeys()
        reloadItems()
    }

    // MARK: - Custom Dataset

    func createDataset(key: String, label: String, color: String) {
        let source = DataSource(key: key, label: label, color: color, items: [])
        do {
            try DatabaseManager.shared.importDataSource(source)
            refreshLoadedKeys()
            reloadItems()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func addItem(_ item: FoodItem, toDataset key: String) {
        do {
            try DatabaseManager.shared.insertItems([item], forSourceKey: key)
            reloadItems()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteItem(id: String, fromDataset key: String) {
        do {
            try DatabaseManager.shared.deleteItem(id: id, sourceKey: key)
            reloadItems()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func exportDataset(key: String) -> Data? {
        do {
            guard let source = try DatabaseManager.shared.source(forKey: key) else { return nil }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(source)
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    func isCustomDataset(key: String) -> Bool {
        !availableKeys.contains(key)
    }

    // MARK: - Local State

    func labelForKey(_ key: String) -> String {
        sourceLabels[key] ?? key
    }

    func refreshLoadedKeys() {
        loadedKeys = (try? DatabaseManager.shared.loadedSourceKeys()) ?? []
        refreshSourceLabels()
    }

    private func refreshSourceLabels() {
        sourceLabels = (try? DatabaseManager.shared.sourceLabels()) ?? [:]
    }

    func reloadItems() {
        allItems = (try? DatabaseManager.shared.allItems()) ?? []
    }
}
