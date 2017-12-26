//
//  ColorThemes.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/24/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    struct Primary {
        //
        static let bgGradTop = UIColor(hex: "E6E8EF")
        static let bgGradBot = UIColor(hex: "D7DAE2")
        //static let bgGradTop = UIColor(hex: "DFE1FE")
        //static let bgGradBot = UIColor(hex: "C1CEFE")
        static let buttonPrimary = UIColor(hex: "56B3FF")
        static let buttonSecondary = UIColor(hex: "FF5964")
        static let title = UIColor.black
    }
    
    struct TriTone {
        static let bgGradTop = UIColor(hex: "E6E8EF")
        static let bgGradBot = UIColor(hex: "D7DAE2")
        //static let bgGradTop = UIColor(hex: "DFE1FE")
        //static let bgGradBot = UIColor(hex: "C1CEFE")
        static let buttonPrimary = UIColor(hex: "56B3FF")
        static let buttonSecondary = UIColor(hex: "FF5964")
        static let title = UIColor.black
    }
    
    struct Azul {
        static let bgGradTop = UIColor(hex: "F4F4F8")
        static let bgGradBot = UIColor(hex: "E9F1DF")
        static let buttonPrimary = UIColor(hex: "4AD9D9")
        static let buttonSecondary = UIColor(hex: "F2385A")
        static let title = UIColor.black
    }
    
    struct TendoLight {
        static let bgGradTop = UIColor(hex: "E6E6EA")
        static let bgGradBot = UIColor(hex: "F4F4F8")
        static let buttonPrimary = UIColor(hex: "25CED1")
        static let buttonSecondary = UIColor(hex: "FF5964")
        static let title = UIColor.black
    }
    
    struct Greeny {
        static let bgGradTop = UIColor(hex: "90BAAD")
        static let bgGradBot = UIColor(hex: "8AA2A9")
        static let buttonPrimary = UIColor(hex: "A1E5AB")
        static let buttonSecondary = UIColor(hex: "A1E5AB")
        static let title = UIColor.black
        //tint = buttonPrimary
    }
    struct Tendo {
        static let bgGradTop = UIColor(hex: "4F6C7A")
        static let bgGradBot = UIColor(hex: "223843")
        static let buttonPrimary = UIColor(hex: "25CED1")
        static let buttonSecondary = UIColor(hex: "FF5964")
        static let title = UIColor.black
        //tint = white
    }
    
    struct Royal {
        static let bgGradTop = UIColor(hex: "3a2b78")
        static let bgGradBot = UIColor(hex: "211950")
        static let buttonPrimary = UIColor(hex: "c4b0ef")
        static let buttonSecondary = UIColor(hex: "c4b0ef")
        static let title = UIColor.white
        //tint = buttonPrimary
    }
    
}
