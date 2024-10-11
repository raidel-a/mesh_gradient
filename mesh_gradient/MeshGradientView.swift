//
//  MeshGradientView.swift
//  mesh_gradient
//
//  Created by Raidel Almeida on 10/10/24.
//

import SwiftUI

struct MeshGradientView: View {
    @ObservedObject var viewModel: MeshGradientViewModel
    let screenGeometry: GeometryProxy
    @Binding var isSheetPresented: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        meshGradientView(in: geometry)
                        pointsView(in: geometry)
                    }
                    .aspectRatio(viewModel.selectedAspectRatio.ratio, contentMode: .fit)
                    .frame(maxWidth: geometry.size.width * 0.90, maxHeight: geometry.size.height * 0.90)
                    .scaleEffect(isSheetPresented ? 0.8 : 1.0, anchor: .top)
                    .animation(.easeInOut, value: isSheetPresented)
                    Spacer()
                }
                Spacer()
            }
        }
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
