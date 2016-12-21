//
//  UIImageExt.swift
//  Yamb
//
//  Created by Kresimir Prcela on 21/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    class func fromColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage
    {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}
