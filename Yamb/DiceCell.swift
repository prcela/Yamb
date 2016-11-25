//
//  DiceCell.swift
//  Yamb
//
//  Created by Kresimir Prcela on 23/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class DiceCell: UICollectionViewCell {
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var icon: UIImageView!
    
    override var selected: Bool {
        didSet {
            holderView.layer.borderWidth = selected ? 2:0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        holderView.layer.borderWidth = 0
        holderView.layer.cornerRadius = 5
        holderView.layer.borderColor = UIColor.whiteColor().CGColor
        holderView.clipsToBounds = true
        
        icon.layer.borderWidth = 0.5
        icon.layer.cornerRadius = 5
        icon.layer.borderColor = UIColor.darkGrayColor().CGColor
        icon.clipsToBounds = true
    }
    
    func update(diceMat: DiceMaterial)
    {
        icon.image = diceIcon(diceMat.rawValue, value: 1)
    }
}
