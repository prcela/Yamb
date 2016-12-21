//
//  UnderlineButton.swift
//  Yamb
//
//  Created by Kresimir Prcela on 23/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class UnderlineButton: UIButton {

    override func draw(_ rect: CGRect)
    {
        // Drawing code
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        // pixel size
        let sortaPixel = 1.0/UIScreen.main.scale
        
        ctx.setStrokeColor(isSelected ? UIColor.red.cgColor : UIColor.darkGray.cgColor)
        ctx.setLineWidth(3)
        
        // middle line
        ctx.move(to: CGPoint(x: 0, y: rect.size.height-sortaPixel/2))
        ctx.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height-sortaPixel/2))
        ctx.strokePath()
        
        ctx.strokePath()
    }
}
