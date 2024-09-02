//
//  UIDevice+Extension.swift
//  mesh_gradient
//
//  Created by Raidel Almeida on 8/31/24.
//

import UIKit

extension UIDevice {
    var cornerRadius: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenSize = min(screenWidth, screenHeight)
        
        switch screenSize {
            case 667: return 10 // iPhone 8, SE2
            case 736: return 12 // iPhone 8 Plus
            case 812: return 39 // iPhone X, XS, 11 Pro, 12 mini, 13 mini
            case 844: return 47 // iPhone 12, 12 Pro, 13, 13 Pro, 14
            case 896: return 39 // iPhone XR, XS Max, 11, 11 Pro Max
            case 926: return 53 // iPhone 12 Pro Max, 13 Pro Max, 14 Plus
            case 932: return 55 // iPhone 14 Pro, 14 Pro Max
            default: return 0
        }
    }
}
