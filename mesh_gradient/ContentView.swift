// ContentView.swift

import SwiftUI

struct ContentView: View {
    // MARK: Internal

    struct ColorPickerSheet: View {
        @ObservedObject var viewModel: MeshGradientViewModel

        var body: some View {
            Form {
                if let (x, y) = viewModel.selectedPointForColorPicker {
                    ColorPicker("Change Color", selection: Binding(
                        get: { viewModel.getPointColor(x: x, y: y) },
                        set: { newColor in
                            viewModel.changePointColor(x: x, y: y, color: newColor)
                        }
                    ))
                    .listRowBackground(Color.white.opacity(0.2))
                }
            }
            .scrollContentBackground(.hidden)
            .presentationDetents([.height(75)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
        }
    }

    var body: some View {
        GeometryReader { screenGeometry in
            ZStack {
                viewModel.averageColor.ignoresSafeArea()
                
                VStack {
//                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            GeometryReader { geometry in
                                ZStack {
                                    meshGradientView(in: geometry)
                                    pointsView(in: geometry)
                                }
                            }
                        }
                        .frame(width: screenGeometry.size.width * 0.95,
                               height: screenGeometry.size.height * 0.95)
                        Spacer()
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        animateButton
                        Spacer()
                        settingsButton
                    }
                }
            }
        }
        .onAppear {
            viewModel.startColorAnimation()
        }
        .onChange(of: viewModel.isColorAnimationEnabled) { isEnabled in
            if isEnabled {
                viewModel.startColorAnimation()
            } else {
                viewModel.stopColorAnimation()
            }
        }
        .onAppear(perform: viewModel.initializeMesh)
        .onChange(of: viewModel.selectedPaletteIndex) { _ in viewModel.updateColors() }
        .onChange(of: viewModel.meshWidth) { _ in viewModel.updateMeshDimensions() }
        .onChange(of: viewModel.meshHeight) { _ in viewModel.updateMeshDimensions() }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $viewModel.showColorPicker) {
            ColorPickerSheet(viewModel: viewModel)
        }
    }
    // MARK: Private

    @StateObject private var viewModel = MeshGradientViewModel()

    private var animateButton: some View {
        Button(action: { viewModel.isColorAnimationEnabled.toggle() }) {
            Image(systemName: viewModel.isColorAnimationEnabled ? "pause.circle" : "play.circle")
                .resizable()
                .scaledToFit()
                .padding(6)
                .frame(width: 45, height: 45)
                .tint(.accentColor.opacity(0.5))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 47))
                .shadow(radius: 2)
        }
        .padding(.leading, 20)
        .padding(.bottom, -10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    private var settingsButton: some View {
        Button(action: { viewModel.showSettings.toggle() }) {
            Image(systemName: "paintbrush")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .frame(width: 45, height: 45)
                .tint(.accentColor.opacity(0.5))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 47))
                .shadow(radius: 2)
        }
        .padding(.trailing, 20)
        .padding(.bottom, -10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }

    private func meshGradientView(in geometry: GeometryProxy) -> some View {
        MeshGradient(
            width: viewModel.meshWidth,
            height: viewModel.meshHeight,
            points: viewModel.points.flatMap { $0 },
            colors: viewModel.currentColors
        )
        .shadow(
            color: viewModel.shadowEnabled ? viewModel.shadowColor : .clear,
            radius: viewModel.shadowRadius,
            x: viewModel.shadowOffset.width,
            y: viewModel.shadowOffset.height
        )
        .gesture(dragGesture(in: geometry))
    }

    private func pointsView(in geometry: GeometryProxy) -> some View {
        Group {
            if viewModel.showPoints {
                ForEach(0 ..< viewModel.meshHeight, id: \.self) { y in
                    ForEach(0 ..< viewModel.meshWidth, id: \.self) { x in
                        if let _ = viewModel.points[safe: y]?[safe: x] {
                            pointCircle(x: x, y: y, in: geometry)
                        }
                    }
                }
            }
        }
    }

    private func pointCircle(x: Int, y: Int, in geometry: GeometryProxy) -> some View {
        let pointColor = viewModel.getPointColor(x: x, y: y)
        let inverseColor = pointColor.inverse()

        return ZStack {
            Circle()
                .fill(pointColor)

            Circle()
                .stroke(inverseColor, lineWidth: 3)
        }
        .frame(width: viewModel.circleSize(for: x, y: y))
        .position(
            x: CGFloat(viewModel.points[safe: y]?[safe: x]?.x ?? 0) * geometry.size.width,
            y: CGFloat(viewModel.points[safe: y]?[safe: x]?.y ?? 0) * geometry.size.height
        )
        .gesture(
            TapGesture()
                .onEnded {
                    viewModel.selectPointForColorPicker(x: x, y: y)
                }
        )
        .simultaneousGesture(dragGesture(in: geometry))
    }

    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                let touchPoint = SIMD2<Float>(
                    Float(value.location.x / geometry.size.width),
                    Float(value.location.y / geometry.size.height)
                )
                withAnimation(.smooth()) {
                    viewModel.movePoint(to: touchPoint)
                }
            }
            .onEnded { _ in
                viewModel.endPointMovement()
            }
    }
}

#Preview {
    ContentView()
}
