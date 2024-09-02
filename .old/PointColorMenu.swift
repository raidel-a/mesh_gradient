//  PointColorMenu.swift

//import SwiftUI
//
//struct PointColorMenu: View {
//        // MARK: Internal
//    @ObservedObject var viewModel: MeshGradientViewModel
//
//    let pointIndex: (Int, Int)
//    
//    var body: some View {
//        VStack {
//            ColorPicker("Select Color", selection: $viewModel.selectedColor)
//                .padding()
//            
//            Button("Apply Color") {
//                viewModel.changePointColor(x: pointIndex.0, y: pointIndex.1)
//            }
//            
//            Button("Remove Color") {
//                viewModel.resetPointColor(x: pointIndex.0, y: pointIndex.1)
//            }
//            
//            Button("Cancel", role: .cancel) {
//                viewModel.selectedPointForMenu = nil
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 5)
//    }
//    
//}
