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
    
    override var isSelected: Bool {
        didSet {
            holderView.layer.borderWidth = isSelected ? 2:0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        holderView.layer.borderWidth = 0
        holderView.layer.cornerRadius = 5
        holderView.layer.borderColor = UIColor.white.cgColor
        holderView.clipsToBounds = true
        
        icon.layer.borderWidth = 0.5
        icon.layer.cornerRadius = 5
        icon.layer.borderColor = UIColor.darkGray.cgColor
        icon.clipsToBounds = true
    }
    
    func update(_ diceMat: DiceMaterial)
    {
        icon.image = diceIcon(diceMat.rawValue, value: 1)
    }
}
