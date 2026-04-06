//
//  DataSource.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import Foundation

struct DataSource: Codable, Identifiable, Hashable {
    var id: String { key }
    let key: String
    let label: String
    let color: String
    let items: [FoodItem]

    enum CodingKeys: String, CodingKey {
        case label, color, items
    }

    var key_: String = ""

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.label = try container.decode(String.self, forKey: .label)
        self.color = try container.decode(String.self, forKey: .color)
        self.items = try container.decode([FoodItem].self, forKey: .items)
        self.key_ = ""
        self.key = ""
    }

    init(key: String, label: String, color: String, items: [FoodItem]) {
        self.key = key
        self.key_ = key
        self.label = label
        self.color = color
        self.items = items
    }

    func withKey(_ key: String) -> DataSource {
        DataSource(key: key, label: label, color: color, items: items)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    static func == (lhs: DataSource, rhs: DataSource) -> Bool {
        lhs.key == rhs.key
    }
}
