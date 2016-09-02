//
//  PrepareViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

private let diceMats:[DiceMaterial] = [.White, .Black, .Rose]

class PrepareViewController: UIViewController {

    @IBOutlet weak var dice56Btn: UIButton?
    @IBOutlet weak var diceTextureBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        diceTextureBtn?.layer.cornerRadius = 5
        diceTextureBtn?.layer.borderColor = UIColor.lightGrayColor().CGColor
        diceTextureBtn?.layer.borderWidth = 1
        diceTextureBtn?.clipsToBounds = true
        updateDiceBtn()
        
        
        
        Chartboost.cacheInterstitial(CBLocationLevelStart)
    }

    func updateDiceBtn()
    {
        let title = lstr("Dice 5/6")
        let thinFont = UIFont(name: "AppleSDGothicNeo-Thin", size: 30)!
        let defaultFont = UIFont(name: "Apple SD Gothic Neo", size: 30)!
        
        let attrString = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.blackColor()
            ])
        
        let loc = title.characters.indexOf(Game.shared.diceNum == .Five ? "5":"6")!
        attrString.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.startIndex.distanceTo(loc), 1))
        
        
        dice56Btn?.setAttributedTitle(attrString, forState: .Normal)
        
        let current = Game.shared.diceMaterial
        diceTextureBtn?.setImage(UIImage(named: "1\(current.rawValue)"), forState: .Normal)
        
    }
    
    @IBAction func toggleDiceCount(sender: AnyObject)
    {
        let old = Game.shared.diceNum
        Game.shared.diceNum = (old == .Five) ? .Six : .Five
        updateDiceBtn()
    }

    @IBAction func newGame(sender: AnyObject)
    {
        performSegueWithIdentifier("newId", sender: self)
    }
    
    @IBAction func resumeGame(sender: AnyObject)
    {
        if let game = GameFileManager.loadGame("singlePlayer")
        {
            Game.shared = game
            GameFileManager.deleteGame("singlePlayer")
        }
        navigationController!.performSegueWithIdentifier("playIdentifier", sender: nil)
    }
    
    @IBAction func changeDiceMaterial(sender: AnyObject)
    {
        let current = Game.shared.diceMaterial
        let idx = diceMats.indexOf(current)!
        let nextIdx = (idx+1)%diceMats.count
        Game.shared.diceMaterial = diceMats[nextIdx]
        diceTextureBtn?.setImage(UIImage(named: "1\(Game.shared.diceMaterial.rawValue)"), forState: .Normal)
    }
    
    @IBAction func playNewGame(sender: AnyObject)
    {
        Game.shared.start([nil])
        navigationController!.performSegueWithIdentifier("playIdentifier", sender: nil)
        
    }

    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
