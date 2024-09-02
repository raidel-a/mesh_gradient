//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    // MARK: Internal

    @ObservedObject var viewModel: MeshGradientViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mesh")) {
                    Toggle("Show Points", isOn: $viewModel.showPoints)

                    Stepper(value: $viewModel.meshWidth, in: 2 ... 10, step: 1) {
                        Text("Columns: \(viewModel.meshWidth)")
                    } onEditingChanged: { _ in
                        viewModel.updateMeshDimensions()
                    }

                    Stepper(value: $viewModel.meshHeight, in: 2 ... 10, step: 1) {
                        Text("Rows: \(viewModel.meshHeight)")
                    } onEditingChanged: { _ in
                        viewModel.updateMeshDimensions()
                    }

                    Button("Reset Mesh", role: .destructive) {
                        viewModel.resetMesh()
                    }
                }
                .listRowBackground(Color.white.opacity(0.2))

                Section(header: Text("Color")) {
                    ColorPicker("Base Color", selection: $paletteManager.baseColor)
                        .onChange(of: paletteManager.baseColor) { _ in
                            paletteManager.generatePalettes()
                            viewModel.updateColors()
                        }

                    Picker("Color Palette", selection: $viewModel.selectedPaletteIndex) {
                        ForEach(0 ..< paletteManager.palettes.count, id: \.self) { index in
                            Text(paletteManager.palettes[index].name)
                        }
                    }

                    Button("Regenerate Palettes") {
                        paletteManager.generatePalettes()
                        viewModel.updateColors()
                    }
                }
                .listRowBackground(Color.white.opacity(0.2))

                Section(header: Text("Color Animation")) {
                    Toggle("Enable Color Animation", isOn: $viewModel.isColorAnimationEnabled)
                    HStack {
                        Text("Speed")
                        Slider(value: $viewModel.colorAnimationSpeed, in: 0.1 ... 5, step: 0.1)
                        Text("\(viewModel.colorAnimationSpeed, specifier: "%.1f")")
                    }
                }
                .listRowBackground(Color.white.opacity(0.2))

                Section(header: Text("Shadow")) {
                    Toggle("Enable Shadow", isOn: $viewModel.shadowEnabled)
                    if viewModel.shadowEnabled {
                        ColorPicker("Shadow Color", selection: $viewModel.shadowColor)
                        HStack {
                            Text("Radius")
                            Slider(value: $viewModel.shadowRadius, in: 0 ... 50, step: 1)
                            Text("\(Int(viewModel.shadowRadius))")
                        }
                        HStack {
                            Text("Offset X")
                            Slider(
                                value: $viewModel.shadowOffset.width,
                                in: -50 ... 50,
                                step: 1
                            )
                            Text("\(Int(viewModel.shadowOffset.width))")
                        }
                        HStack {
                            Text("Offset Y")
                            Slider(
                                value: $viewModel.shadowOffset.height,
                                in: -50 ... 50,
                                step: 1
                            )
                            Text("\(Int(viewModel.shadowOffset.height))")
                        }
                    }
                }.listRowBackground(Color.white.opacity(0.2))
            }.padding(.top)
        }
//        .background(.thinMaterial)
        .scrollContentBackground(.hidden)
    }

    // MARK: Private

    @State private var paletteManager = ColorPaletteManager.shared
}
