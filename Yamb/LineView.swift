//
//  LineView.swift
//  Yamb
//
//  Created by Kresimir Prcela on 17/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

class LineView: UIView
{
    var fillColor: UIColor!
    
    override func awakeFromNib() {
        fillColor = backgroundColor
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
    }
    
    override func draw(_ rect: CGRect)
    {
        // Drawing code
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        // pixel size
        let sortaPixel = 1.0/UIScreen.main.scale
        
        // middle line
        ctx.setStrokeColor(fillColor.cgColor)
        ctx.move(to: CGPoint(x: 0, y: 1-sortaPixel/2))
        ctx.addLine(to: CGPoint(x: rect.size.width, y: 1-sortaPixel/2))
        
        ctx.strokePath()
    }
    
}
