//
//  DatasetEditorView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI
import UniformTypeIdentifiers

struct DatasetEditorView: View {

    @Environment(DatasetManager.self) var datasetManager
    @Environment(\.dismiss) var dismiss

    let datasetKey: String

    @State private var items: [FoodItem] = []
    @State private var datasetLabel: String = ""
    @State private var showingAddItem = false
    @State private var exportData: Data?
    @State private var showingExporter = false

    var body: some View {
        List {
            Section {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.body)
                        HStack(spacing: 6) {
                            Text("\(Int(item.cal))kcal")
                            Text("P\(String(format: "%.1f", item.p))g")
                            Text("F\(String(format: "%.1f", item.f))g")
                            Text("C\(String(format: "%.1f", item.c))g")
                            Text("Fi\(String(format: "%.1f", item.fi))g")
                        }
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            datasetManager.deleteItem(id: item.id, fromDataset: datasetKey)
                            reloadItems()
                        } label: {
                            Label("Shared.Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .orangeGradientBackground()
        .navigationTitle(datasetLabel)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("DatasetEditor.AddItem", systemImage: "plus")
                    }
                    Button {
                        exportData = datasetManager.exportDataset(key: datasetKey)
                        if exportData != nil {
                            showingExporter = true
                        }
                    } label: {
                        Label("DatasetEditor.Export", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            FoodItemEditorView { item in
                datasetManager.addItem(item, toDataset: datasetKey)
                reloadItems()
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: JSONExportDocument(data: exportData ?? Data()),
            contentType: .json,
            defaultFilename: "\(datasetKey).json"
        ) { _ in }
        .onAppear {
            reloadItems()
            if let source = try? DatabaseManager.shared.source(forKey: datasetKey) {
                datasetLabel = source.label
            }
        }
    }

    private func reloadItems() {
        items = (try? DatabaseManager.shared.items(forSourceKey: datasetKey)) ?? []
    }
}

struct JSONExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
