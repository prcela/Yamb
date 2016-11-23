//
//  UnderlineButton.swift
//  Yamb
//
//  Created by Kresimir Prcela on 23/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class UnderlineButton: UIButton {

    override func drawRect(rect: CGRect)
    {
        // Drawing code
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        // pixel size
        let sortaPixel = 1.0/UIScreen.mainScreen().scale
        
        CGContextSetStrokeColorWithColor(ctx, selected ? UIColor.redColor().CGColor : UIColor.darkGrayColor().CGColor)
        CGContextSetLineWidth(ctx, 3)
        
        // middle line
        CGContextMoveToPoint(ctx, 0, rect.size.height-sortaPixel/2)
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height-sortaPixel/2)
        CGContextStrokePath(ctx)
        
        CGContextStrokePath(ctx)
    }
}
