//  ColorPalettes.swift

import SwiftUI
import Combine

struct ColorPalette: Identifiable {
    let id = UUID()
    let name: String
    let colors: [Color]
}

class ColorPaletteManager: ObservableObject {
    // MARK: Lifecycle

    init() {
        generatePalettes()
    }

    // MARK: Internal

    static let shared = ColorPaletteManager()

    @Published var palettes: [ColorPalette] = []
    @Published var baseColor: Color = .blue

    func generatePalettes() {
        palettes = [
            ColorPalette(name: "Monochromatic", colors: ColorPaletteGenerator.generateMonochromaticPalette(baseColor: baseColor, count: 8)),
            ColorPalette(name: "Complementary", colors: ColorPaletteGenerator.generateComplementaryPalette(baseColor: baseColor, count: 8)),
            ColorPalette(name: "Analogous", colors: ColorPaletteGenerator.generateAnalogousPalette(baseColor: baseColor, count: 8)),
            ColorPalette(name: "Triadic", colors: ColorPaletteGenerator.generateTriadicPalette(baseColor: baseColor, count: 9)),
            ColorPalette(name: "Tetradic", colors: ColorPaletteGenerator.generateTetradicPalette(baseColor: baseColor, count: 8)),
            ColorPalette(name: "Split-Complementary", colors: ColorPaletteGenerator.generateSplitComplementaryPalette(baseColor: baseColor, count: 9)),
            ColorPalette(name: "Random", colors: (0 ..< 8).map { _ in Color.random() }),
        ]
    }

    func getRandomColors(from palette: ColorPalette, count: Int) -> [Color] {
        return Array(palette.colors.shuffled().prefix(count))
    }
}

class ColorPaletteGenerator {
    // MARK: Internal

    static func generateMonochromaticPalette(baseColor: Color, count: Int) -> [Color] {
        let (h, s, b, _) = baseColor.hsbComponents
        return (0 ..< count).map { i in
            Color(hue: h,
                  saturation: max(0, min(1, s + Double(i) * 0.1 - 0.3)),
                  brightness: max(0, min(1, b + Double(i) * 0.1 - 0.3)))
        }
    }

    static func generateComplementaryPalette(baseColor: Color, count: Int) -> [Color] {
        let hue = baseColor.hsbComponents.hue
        let complementaryHue = (hue + 0.5).truncatingRemainder(dividingBy: 1.0)
        return generatePalette(baseHue: complementaryHue, count: count)
    }

    static func generateAnalogousPalette(baseColor: Color, count: Int) -> [Color] {
        let hue = baseColor.hsbComponents.hue
        return generatePalette(baseHue: hue, hueRange: 0.083, count: count)
    }

    static func generateTriadicPalette(baseColor: Color, count: Int) -> [Color] {
        let hue = baseColor.hsbComponents.hue
        let hues = [hue, (hue + 1 / 3).truncatingRemainder(dividingBy: 1.0), (hue + 2 / 3).truncatingRemainder(dividingBy: 1.0)]
        return hues.flatMap { generatePalette(baseHue: $0, count: count / 3) }
    }

    static func generateTetradicPalette(baseColor: Color, count: Int) -> [Color] {
        let hue = baseColor.hsbComponents.hue
        let hues = [hue, (hue + 0.25).truncatingRemainder(dividingBy: 1.0),
                    (hue + 0.5).truncatingRemainder(dividingBy: 1.0),
                    (hue + 0.75).truncatingRemainder(dividingBy: 1.0)]
        return hues.flatMap { generatePalette(baseHue: $0, count: count / 4) }
    }

    static func generateSplitComplementaryPalette(baseColor: Color, count: Int) -> [Color] {
        let hue = baseColor.hsbComponents.hue
        let hues = [hue, (hue + 0.5833).truncatingRemainder(dividingBy: 1.0), (hue + 0.9167).truncatingRemainder(dividingBy: 1.0)]
        return hues.flatMap { generatePalette(baseHue: $0, count: count / 3) }
    }

    // MARK: Private

    private static func generatePalette(baseHue: Double, hueRange: Double = 0, count: Int) -> [Color] {
        return (0 ..< count).map { i in
            let hue = (baseHue + Double(i) * hueRange / Double(count)).truncatingRemainder(dividingBy: 1.0)
            return Color(hue: hue, saturation: 0.7 + Double.random(in: -0.2 ... 0.2), brightness: 0.7 + Double.random(in: -0.2 ... 0.2))
        }
    }
}

extension Color {
    var hsbComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }

    var hue: Double {
        let uiColor = UIColor(self)
        var h: CGFloat = 0
        uiColor.getHue(&h, saturation: nil, brightness: nil, alpha: nil)
        return Double(h) * 360
    }

    static func random() -> Color {
        return Color(red: .random(in: 0 ... 1), green: .random(in: 0 ... 1), blue: .random(in: 0 ... 1))
    }

    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    func inverse() -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return Color(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let a = try container.decode(Double.self, forKey: .alpha)
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let components = self.components
        try container.encode(components.red, forKey: .red)
        try container.encode(components.green, forKey: .green)
        try container.encode(components.blue, forKey: .blue)
        try container.encode(components.alpha, forKey: .alpha)
    }
}