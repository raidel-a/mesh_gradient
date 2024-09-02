//
//  Sheet+Extensions.swift
//  mesh_gradient
//
//  Created by Raidel Almeida on 8/31/24.
//
import SwiftUI
import UIKit

struct SheetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .presentationBackground(.thinMaterial)
    }
}

extension View {
    func thinMaterialSheet() -> some View {
        self.modifier(SheetBackgroundModifier())
    }
}

struct ThinMaterialBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
    }
}
