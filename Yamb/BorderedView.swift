//
//  BorderedView.swift
//  Yamb
//
//  Created by Kresimir Prcela on 21/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedView: UIView {

    @IBInspectable var lineColor:UIColor = UIColor.blackColor()
    @IBInspectable var top:Bool = true
    @IBInspectable var bottom:Bool = true
    @IBInspectable var left:Bool = true
    @IBInspectable var right:Bool = true
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func drawRect(rect: CGRect)
    {
        // Drawing code
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        // pixel size
        let sortaPixel = 1.0/UIScreen.mainScreen().scale
        CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor)
        
        if top
        {
            CGContextMoveToPoint(ctx, 0, sortaPixel/2)
            CGContextAddLineToPoint(ctx, rect.size.width, sortaPixel/2)
            CGContextStrokePath(ctx)
        }
        
        if bottom
        {
            CGContextMoveToPoint(ctx, 0, rect.size.height-sortaPixel/2)
            CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height-sortaPixel/2)
            CGContextStrokePath(ctx)
        }
        
        if left
        {
            CGContextMoveToPoint(ctx, sortaPixel/2, 0)
            CGContextAddLineToPoint(ctx, sortaPixel/2, rect.size.height)
            CGContextStrokePath(ctx)
        }
        
        if right
        {
            CGContextMoveToPoint(ctx, rect.size.width-sortaPixel/2, 0)
            CGContextAddLineToPoint(ctx, rect.size.width-sortaPixel/2, rect.size.height)
            CGContextStrokePath(ctx)
        }
        
    }

}
