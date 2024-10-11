//
//  ControlesView.swift
//  mesh_gradient
//
//  Created by Raidel Almeida on 10/10/24.
//

import Foundation
import SwiftUI

struct ControlsView: View {
    let viewModel: MeshGradientViewModel

    var body: some View {
        VStack {
            Spacer()
            HStack {
                animateButton
                Spacer()
                settingsButton
            }
            .padding(.bottom, -10) // Add some bottom padding to the HStack
        }
    }

    private var animateButton: some View {
        Button(action: { viewModel.isColorAnimationEnabled.toggle() }) {
            Image(systemName: viewModel.isColorAnimationEnabled ? "pause.circle" : "play.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24) // Specify a smaller fixed size
                .padding(8) // Reduce padding inside the button
                .tint(.accentColor.opacity(0.5))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 2)
        }
        .padding(.leading, 16) // Reduce leading padding
    }

    private var settingsButton: some View {
        Button(action: { viewModel.showSettings.toggle() }) {
            Image(systemName: "paintbrush")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24) // Specify a smaller fixed size
                .padding(8) // Reduce padding inside the button
                .tint(.accentColor.opacity(0.5))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 2)
        }
        .padding(.trailing, 16) // Reduce trailing padding
    }
}
