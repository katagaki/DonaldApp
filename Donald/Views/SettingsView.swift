//
//  SettingsView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct TargetRow: View {
    let label: String
    @Binding var value: Double
    let step: Double
    let unit: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Button {
                value = max(0, value - step)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            Text("\(Int(value))\(unit)")
                .monospacedDigit()
                .frame(minWidth: 70, alignment: .center)
            Button {
                value += step
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
    }
}
