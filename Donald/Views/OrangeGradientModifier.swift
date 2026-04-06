//
//  OrangeGradientModifier.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct OrangeGradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background {
                LinearGradient(
                    colors: [
                        Color("GradientTop"),
                        Color("GradientBottom")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
    }
}

extension View {
    func orangeGradientBackground() -> some View {
        modifier(OrangeGradientBackground())
    }
}
