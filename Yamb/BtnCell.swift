//
//  BtnCell.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class BtnCell: UICollectionViewCell {
    
    @IBOutlet weak var btn: UIButton!
    
    override func awakeFromNib() {
        layer.borderWidth = 0.5
    }
}
