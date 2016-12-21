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

    @IBInspectable var lineColor:UIColor = UIColor.black
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
    
    override func draw(_ rect: CGRect)
    {
        // Drawing code
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        // pixel size
        let sortaPixel = 1.0/UIScreen.main.scale
        ctx.setStrokeColor(lineColor.cgColor)
        
        if top
        {
            ctx.move(to: CGPoint(x: 0, y: sortaPixel/2))
            ctx.addLine(to: CGPoint(x: rect.size.width, y: sortaPixel/2))
            ctx.strokePath()
        }
        
        if bottom
        {
            ctx.move(to: CGPoint(x: 0, y: rect.size.height-sortaPixel/2))
            ctx.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height-sortaPixel/2))
            ctx.strokePath()
        }
        
        if left
        {
            ctx.move(to: CGPoint(x: sortaPixel/2, y: 0))
            ctx.addLine(to: CGPoint(x: sortaPixel/2, y: rect.size.height))
            ctx.strokePath()
        }
        
        if right
        {
            ctx.move(to: CGPoint(x: rect.size.width-sortaPixel/2, y: 0))
            ctx.addLine(to: CGPoint(x: rect.size.width-sortaPixel/2, y: rect.size.height))
            ctx.strokePath()
        }
        
    }

}
