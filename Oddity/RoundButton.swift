//
//  RoundButton.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/20/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton
{
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    @IBInspectable var flatTop: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    @IBInspectable var flatLeft: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    @IBInspectable var circular: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    @IBInspectable var radius: CGFloat = 0.0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        let rectShape = CAShapeLayer()
        let rad = circular ? frame.size.height / 2 : radius
        rectShape.bounds = self.frame
        rectShape.position = self.center
        var corners:UIRectCorner = flatTop ? [.bottomLeft, .bottomRight] : [.bottomLeft , .bottomRight , .topLeft, .topRight]
        
        if flatLeft {
            corners = [.bottomRight, .topRight]
        }
        
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: rad, height: rad)).cgPath
        
        //Here I'm masking the textView's layer with rectShape layer
        layer.mask = rectShape
    }
}
