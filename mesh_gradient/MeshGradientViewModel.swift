//  MeshGradientViewModel.swift

import Combine
import SwiftUI

class MeshGradientViewModel: ObservableObject {
    // MARK: Internal

    @Published var meshWidth: Int = 3
    @Published var meshHeight: Int = 3
    @Published var points: [[SIMD2<Float>]] = []
    @Published var showPoints = true
    @Published var currentColors: [Color] = []
    @Published var selectedPaletteIndex = 0

    @Published var shadowEnabled = true
    @Published var shadowColor = Color.black
    @Published var shadowRadius: CGFloat = 25
//    @Published var shadowOffsetX: CGFloat = 0
//    @Published var shadowOffsetY: CGFloat = 0
    @Published var shadowOffset = CGSize(width: 0, height: 0)

    @Published var showSettings = false
    @Published var selectedPointForMenu: (Int, Int)? = nil
    @Published var selectedColor: Color = .white
    @Published var showColorPicker = false
    @Published var selectedPointForColorPicker: (x: Int, y: Int)?

    @Published var isColorAnimationEnabled = false
    @Published var colorAnimationSpeed: Double = 1.0
    @Published var colorAnimationProgress: Double = 0.0

    @Published private(set) var movingPointIndex: (Int, Int)?
    
    @Published var averageColor: Color = .clear

    func initializeMesh() {
        points = (0 ..< meshHeight).map { y in
            (0 ..< meshWidth).map { x in
                SIMD2<Float>(Float(x) / Float(max(1, meshWidth - 1)), Float(y) / Float(max(1, meshHeight - 1)))
            }
        }
        updateColors()
    }

    func updateColors() {
        let totalPoints = meshWidth * meshHeight
        let palette = ColorPaletteManager.shared.palettes[selectedPaletteIndex].colors
        let paletteCount = palette.count

        currentColors = (0 ..< totalPoints).map { index in
            let normalizedIndex = Double(index % paletteCount) / Double(paletteCount)
            let adjustedProgress = (normalizedIndex + colorAnimationProgress).truncatingRemainder(dividingBy: 1.0)
            return interpolateColorFromPalette(palette: palette, progress: adjustedProgress)
        }
        averageColor = calculateAverageColor()

    }

    func resetMesh() {
        points = (0 ..< meshHeight).map { y in
            (0 ..< meshWidth).map { x in
                SIMD2(Float(x) / Float(meshWidth - 1), Float(y) / Float(meshHeight - 1))
            }
        }
        updateColors()
    }

    func isMovingPoint(x: Int, y: Int) -> Bool {
        movingPointIndex.map { $0 == (x, y) } == true
    }

    func movePoint(to touchPoint: SIMD2<Float>) {
        if movingPointIndex == nil {
            movingPointIndex = findNearestPoint(to: touchPoint)
        }

        guard let (x, y) = movingPointIndex else { return }

        let moveThreshold: Float = 0.01
        let currentPoint = points[y][x]
        let distance = sqrt(pow(touchPoint.x - currentPoint.x, 2) + pow(touchPoint.y - currentPoint.y, 2))

        if distance > moveThreshold {
            let interpolationFactor: Float = 0.5
            points[y][x] = SIMD2<Float>(
                currentPoint.x + (touchPoint.x - currentPoint.x) * interpolationFactor,
                currentPoint.y + (touchPoint.y - currentPoint.y) * interpolationFactor
            )
        }
    }

    func endPointMovement() {
        movingPointIndex = nil
    }

    func findNearestPoint(to touchPoint: SIMD2<Float>) -> (Int, Int) {
        var nearestIndex = (0, 0)
        var nearestDistance = Float.infinity

        for y in 0 ..< meshHeight {
            for x in 0 ..< meshWidth {
                let distance = calculateDistance(points[y][x], touchPoint)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestIndex = (x, y)
                }
            }
        }

        return nearestIndex
    }

    func calculateDistance(_ a: SIMD2<Float>, _ b: SIMD2<Float>) -> Float {
        let diff = a - b
        return sqrt(diff.x * diff.x + diff.y * diff.y)
    }

    func updateMeshDimensions() {
        while meshWidth > points[0].count {
            addColumn()
        }
        while meshWidth < points[0].count {
            removeColumn()
        }
        while meshHeight > points.count {
            addRow()
        }
        while meshHeight < points.count {
            removeRow()
        }
        updateColors()
    }

    func circleSize(for x: Int, y: Int) -> CGFloat {
        return (movingPointIndex ?? (-1, -1)) == (x, y) ? 25 : 20
    }

    func getPointColor(x: Int, y: Int) -> Color {
        guard x < meshWidth && y < meshHeight else { return .white }
        let index = y * meshWidth + x
        return currentColors[safe: index] ?? .white
    }

    func changePointColor(x: Int, y: Int, color: Color) {
        guard x < meshWidth && y < meshHeight else { return }
        let index = y * meshWidth + x
        if index < currentColors.count {
            currentColors[index] = color
        }
    }

    func resetPointColor(x: Int, y: Int) {
        guard x < meshWidth && y < meshHeight else { return }
        let index = y * meshWidth + x
        if index < currentColors.count {
            currentColors[index] = .white
        }
    }

    func startColorAnimation() {
        stopColorAnimation()
        colorAnimationTimer = Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isColorAnimationEnabled else { return }
                self.updateColorAnimation()
            }
    }

    func stopColorAnimation() {
        colorAnimationTimer?.cancel()
        colorAnimationTimer = nil
    }

    func selectPointForColorPicker(x: Int, y: Int) {
        selectedPointForColorPicker = (x, y)
        showColorPicker = true
    }

    // MARK: Private

    private let maxMeshDimension = 10
    private let minMeshDimension = 2

    private var colorAnimationTimer: AnyCancellable?

    private func addRow() {
        guard points.count < 10 else { return }
        let newRow = (0 ..< meshWidth).map { x in
            SIMD2<Float>(Float(x) / Float(max(1, meshWidth - 1)), 1.0)
        }
        points.append(newRow)
    }

    private func removeRow() {
        guard points.count > 2 else { return }
        points.removeLast()
    }

    private func addColumn() {
        guard points[0].count < 10 else { return }
        for y in 0 ..< points.count {
            let x = Float(points[0].count) / Float(max(1, points[0].count))
            points[y].append(SIMD2<Float>(x, Float(y) / Float(max(1, points.count - 1))))
        }
    }

    private func removeColumn() {
        guard points[0].count > 2 else { return }
        for y in 0 ..< points.count {
            points[y].removeLast()
        }
    }

    private func updateColorAnimation() {
        colorAnimationProgress += 0.001 * colorAnimationSpeed
        if colorAnimationProgress >= 1.0 {
            colorAnimationProgress -= 1.0
        }
        updateColors()
    }

    private func interpolateColorFromPalette(palette: [Color], progress: Double) -> Color {
        let paletteCount = Double(palette.count)
        let index = Int(floor(progress * paletteCount))
        let nextIndex = (index + 1) % palette.count
        let colorProgress = (progress * paletteCount).truncatingRemainder(dividingBy: 1.0)

        return interpolateColor(from: palette[index], to: palette[nextIndex], progress: colorProgress)
    }

    private func interpolateColor(from: Color, to: Color, progress: Double) -> Color {
        let fromComponents = from.components
        let toComponents = to.components

        let r = fromComponents.red + (toComponents.red - fromComponents.red) * progress
        let g = fromComponents.green + (toComponents.green - fromComponents.green) * progress
        let b = fromComponents.blue + (toComponents.blue - fromComponents.blue) * progress

        return Color(red: r, green: g, blue: b)
    }
    
    func calculateAverageColor() -> Color {
        guard !currentColors.isEmpty else { return .clear }
        
        let components = currentColors.map { color -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) in
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return (red, green, blue, alpha)
        }
        
        let avgRed = components.map { $0.red }.reduce(0, +) / CGFloat(components.count)
        let avgGreen = components.map { $0.green }.reduce(0, +) / CGFloat(components.count)
        let avgBlue = components.map { $0.blue }.reduce(0, +) / CGFloat(components.count)
        let avgAlpha = components.map { $0.alpha }.reduce(0, +) / CGFloat(components.count)
        
        return Color(red: Double(avgRed), green: Double(avgGreen), blue: Double(avgBlue), opacity: Double(avgAlpha))
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
