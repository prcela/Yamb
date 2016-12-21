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
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: frame.size.height/2))
        path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height/2))
        path.closeSubpath()
        
        animShapeLayer.path = path
        animShapeLayer.strokeColor = UIColor.red.cgColor
        animShapeLayer.fillColor = UIColor.clear.cgColor
        animShapeLayer.lineWidth = 3
        
        layer.addSublayer(animShapeLayer)
        
        print("layoutSubviews()")
    }
    
    func animateShape(_ duration: TimeInterval)
    {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.speed = 0.5
        
        // Your new shape here
        animation.fromValue = 0
        animation.toValue = 1
        
        animation.fillMode = kCAFillModeRemoved
        animation.isRemovedOnCompletion = false
        
        animShapeLayer.add(animation, forKey: "drawAnimation")
    }
    
    func removeAnimation()
    {
        animShapeLayer.removeAllAnimations()
    }
}
