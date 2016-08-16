//
//  LblCell.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class LblCell: UICollectionViewCell {
    @IBOutlet weak var lbl: UILabel!
    
    override func awakeFromNib() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGrayColor().CGColor
    }
}
