//
//  ProgressView.swift
//  Yamb
//
//  Created by Kresimir Prcela on 11/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class ProgressView: UIView
{

    let animShapeLayer = CAShapeLayer()

    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        animShapeLayer.removeFromSuperlayer()
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, frame.size.height/2)
        CGPathAddLineToPoint(path, nil, frame.size.width, frame.size.height/2)
        CGPathCloseSubpath(path)
        
        animShapeLayer.path = path
        animShapeLayer.strokeColor = UIColor.redColor().CGColor
        animShapeLayer.fillColor = UIColor.clearColor().CGColor
        animShapeLayer.lineWidth = 2
        
        layer.addSublayer(animShapeLayer)
        
        print("layoutSubviews()")
    }
    
    func animateShape(duration: NSTimeInterval)
    {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.speed = 0.5
        
        // Your new shape here
        animation.fromValue = 0
        animation.toValue = 1
        
        animation.fillMode = kCAFillModeRemoved
        animation.removedOnCompletion = false
        
        animShapeLayer.addAnimation(animation, forKey: "drawAnimation")
    }
    
    func removeAnimation()
    {
        animShapeLayer.removeAllAnimations()
    }
}
