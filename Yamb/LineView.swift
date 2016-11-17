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
        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = false
    }
    
    override func drawRect(rect: CGRect)
    {
        // Drawing code
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        // pixel size
        let sortaPixel = 1.0/UIScreen.mainScreen().scale
        
        // middle line
        CGContextSetStrokeColorWithColor(ctx, fillColor.CGColor)
        CGContextMoveToPoint(ctx, 0, 1-sortaPixel/2)
        CGContextAddLineToPoint(ctx, rect.size.width, 1-sortaPixel/2)
        
        CGContextStrokePath(ctx)
    }
    
}
