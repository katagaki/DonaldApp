//
//  DonaldApp.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

@main
struct DonaldApp: App {

    @State private var datasetManager = DatasetManager()
    @State private var planManager = PlanManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(datasetManager)
                .environment(planManager)
        }
    }
}
