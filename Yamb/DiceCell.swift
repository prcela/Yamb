//
//  DiceCell.swift
//  Yamb
//
//  Created by Kresimir Prcela on 23/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class DiceCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        icon.layer.borderWidth = 1
        icon.layer.cornerRadius = 5
        icon.layer.borderColor = UIColor.darkGrayColor().CGColor
        icon.clipsToBounds = true
    }
    
    func update(diceMat: DiceMaterial)
    {
        icon.image = UIImage(named: "1\(diceMat.rawValue)")
    }
}
