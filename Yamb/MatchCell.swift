//
//  MatchCell.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {

    @IBOutlet weak var diceIconFirst: UIImageView!
    @IBOutlet weak var diceIconSecond: UIImageView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        for icon in [diceIconFirst,diceIconSecond]
        {
            icon.layer.cornerRadius = 2.5
            icon.layer.borderColor = UIColor.lightGrayColor().CGColor
            icon.layer.borderWidth = 0.5
            icon.clipsToBounds = true
        }
    }

}
