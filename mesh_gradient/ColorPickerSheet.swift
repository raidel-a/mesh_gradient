//
//  ColorPickerSheet.swift
//  mesh_gradient
//
//  Created by Raidel Almeida on 10/10/24.
//

import SwiftUI

struct ColorPickerSheet: View {
    @ObservedObject var viewModel: MeshGradientViewModel
    @State private var selectedColor: Color = .white

    var body: some View {
        Form {
            if let (x, y) = viewModel.selectedPointForColorPicker {
                ColorPicker("Change Color", selection: $selectedColor)
                    .onChange(of: selectedColor) { newColor in
                        viewModel.changePointColor(x: x, y: y, color: newColor)
                    }
                    .onAppear {
                        selectedColor = viewModel.getPointColor(x: x, y: y)
                    }
                    .listRowBackground(Color.white.opacity(0.2))
                
                Button("Reset Color") {
                    viewModel.resetPointColor(x: x, y: y)
                    selectedColor = viewModel.getPointColor(x: x, y: y)
                }
                .listRowBackground(Color.white.opacity(0.2))
                
                Button("Reset Position") {
                    viewModel.resetPointPosition(x: x, y: y)
                }
                .listRowBackground(Color.white.opacity(0.2))
            }
        }
        .scrollContentBackground(.hidden)
        .presentationDetents([.height(150)]) // Increased height to accommodate new buttons
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
    }
}