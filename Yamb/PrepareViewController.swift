//
//  PrepareViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PrepareViewController: UIViewController {

    @IBOutlet weak var dice56Btn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func play(sender: AnyObject)
    {
        navigationController!.performSegueWithIdentifier("playIdentifier", sender: nil)
    }
    
    @IBAction func playNewGame(sender: AnyObject)
    {
        navigationController!.performSegueWithIdentifier("playIdentifier", sender: nil)
        Game.shared.start()
    }

    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
