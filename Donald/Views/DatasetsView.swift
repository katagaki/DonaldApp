//
//  DatasetsView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI
import UniformTypeIdentifiers

struct DatasetsView: View {

    @Environment(DatasetManager.self) var datasetManager
    @State private var showingImporter = false
    @State private var showingNewDataset = false
    @State private var newDatasetName = ""

    var customKeys: [String] {
        datasetManager.loadedKeys
            .filter { datasetManager.isCustomDataset(key: $0) }
            .sorted { lhs, rhs in
                lhs.localizedCompare(rhs) == .orderedAscending
            }
    }

    var body: some View {
        NavigationStack {
            List {
                if datasetManager.isLoadingKeys {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Datasets.Loading")
                            Spacer()
                        }
                    }
                } else if !datasetManager.availableKeys.isEmpty {
                    Section("Datasets.Available") {
                        ForEach(datasetManager.availableKeys.sorted { lhs, rhs in
                            DatasetRow.displayName(for: lhs).localizedCompare(DatasetRow.displayName(for: rhs)) == .orderedAscending
                        }, id: \.self) { key in
                            DatasetRow(
                                key: key,
                                isLoaded: datasetManager.loadedKeys.contains(key),
                                isDownloading: datasetManager.downloadingKeys.contains(key),
                                onDownload: {
                                    Task {
                                        await datasetManager.downloadDataset(key: key)
                                    }
                                },
                                onDelete: {
                                    datasetManager.deleteDataset(key: key)
                                }
                            )
                        }
                    }
                }

                Section {
                    if !customKeys.isEmpty {
                        ForEach(customKeys, id: \.self) { key in
                            NavigationLink(destination: DatasetEditorView(datasetKey: key)) {
                                Text(DatasetRow.displayName(for: key))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    datasetManager.deleteDataset(key: key)
                                } label: {
                                    Label("Shared.Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    Button {
                        showingNewDataset = true
                    } label: {
                        Label("Datasets.Create", systemImage: "plus")
                    }
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Datasets.Import", systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("Datasets.Custom")
                }

                if let error = datasetManager.error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .orangeGradientBackground()
            .navigationTitle("Datasets.Title")
            .task {
                await datasetManager.fetchAvailableDatasets()
            }
            .refreshable {
                await datasetManager.fetchAvailableDatasets()
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        do {
                            try datasetManager.importJSON(from: url)
                        } catch {
                            datasetManager.error = error.localizedDescription
                        }
                    }
                case .failure(let error):
                    datasetManager.error = error.localizedDescription
                }
            }
            .alert("Datasets.Create", isPresented: $showingNewDataset) {
                TextField("Datasets.Create.Placeholder", text: $newDatasetName)
                Button("Shared.Save") {
                    let trimmed = newDatasetName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        let key = trimmed.lowercased()
                            .replacingOccurrences(of: " ", with: "_")
                        datasetManager.createDataset(key: key, label: trimmed, color: "#888888")
                        newDatasetName = ""
                    }
                }
                Button("Shared.Cancel", role: .cancel) {
                    newDatasetName = ""
                }
            }
        }
    }
}

struct DatasetRow: View {
    let key: String
    let isLoaded: Bool
    let isDownloading: Bool
    let onDownload: () -> Void
    let onDelete: () -> Void

    static func displayName(for key: String) -> String {
        switch key {
        case "seveneleven": String(localized: "Datasets.Source.SevenEleven")
        case "nosh": String(localized: "Datasets.Source.Nosh")
        case "mcdonalds": String(localized: "Datasets.Source.McDonalds")
        case "koubo": String(localized: "Datasets.Source.Koubo")
        case "boss": String(localized: "Datasets.Source.Boss")
        case "acure": String(localized: "Datasets.Source.Acure")
        case "suntory": String(localized: "Datasets.Source.Suntory")
        case "kirin": String(localized: "Datasets.Source.Kirin")
        case "ucc": String(localized: "Datasets.Source.Ucc")
        default: key
        }
    }

    var displayName: String {
        Self.displayName(for: key)
    }

    var body: some View {
        HStack {
            Text(displayName)
                .font(.body)
            Spacer()
            if isDownloading {
                ProgressView()
            } else if !isLoaded {
                Button(action: onDownload) {
                    Image(systemName: "icloud.and.arrow.down")
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if isLoaded {
                Button(role: .destructive, action: onDelete) {
                    Label("Shared.Delete", systemImage: "trash")
                }
            }
        }
    }
}
