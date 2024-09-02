//
//  BottomSheetView.swift
//  mesh_gradient
//
//  Created by Raidel Almeida on 8/31/24.
//
import SwiftUI

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
                
                VStack {
                    Spacer()
                    sheetContent()
                        .background(Color.white)
                        .cornerRadius(16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .transition(.identity)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: isPresented)
    }
}

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(BottomSheetModifier(isPresented: isPresented, sheetContent: content))
    }
}


