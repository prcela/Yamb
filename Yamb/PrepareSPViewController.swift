//
//  PrepareViewController.swift
//  Yamb
//
//  Created by prcela on 02/04/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PrepareSPViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton?
    @IBOutlet weak var resumeBtn: UIButton?
    @IBOutlet weak var newGameBtn: UIButton?
    @IBOutlet weak var dice56Btn: UIButton?
    @IBOutlet weak var diceTextureBtn: UIButton?
    @IBOutlet weak var playBtn: UIButton?
    
    var diceMatSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // localization
        backBtn?.setTitle(lstr("Back"), for: UIControlState())
        resumeBtn?.setTitle(lstr("Resume game"), for: UIControlState())
        newGameBtn?.setTitle(lstr("New game"), for: UIControlState())
        playBtn?.setTitle(lstr("Play"), for: UIControlState())

        // Do any additional setup after loading the view.
        
        diceTextureBtn?.layer.cornerRadius = 5
        diceTextureBtn?.layer.borderColor = UIColor.lightGray.cgColor
        diceTextureBtn?.layer.borderWidth = 1
        diceTextureBtn?.clipsToBounds = true
        
        diceMatSelected = PlayerStat.shared.ownedDiceMaterials().index(of: PlayerStat.shared.favDiceMat)!
        updateDiceBtn()
        
    }

    func updateDiceBtn()
    {
        let title = lstr("Dice 5/6")
        let thinFont = UIFont.systemFont(ofSize: 30, weight: UIFontWeightThin)
        let defaultFont = UIFont.systemFont(ofSize: 30)
        
        let attrString = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.black
            ])
        
        let loc = title.characters.index(of: Match.shared.diceNum == .five ? "5":"6")!
        attrString.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.characters.distance(from: title.startIndex, to: loc), 1))
        
        
        dice56Btn?.setAttributedTitle(attrString, for: UIControlState())
        
        let current = PlayerStat.shared.ownedDiceMaterials()[diceMatSelected]
        diceTextureBtn?.setImage(current.iconForValue(1), for: UIControlState())
        
    }
    
    @IBAction func toggleDiceCount(_ sender: AnyObject)
    {
        let old = Match.shared.diceNum
        Match.shared.diceNum = (old == .five) ? .six : .five
        updateDiceBtn()
    }

    @IBAction func newGame(_ sender: AnyObject)
    {
        performSegue(withIdentifier: "newId", sender: self)
    }
    
    @IBAction func resumeGame(_ sender: AnyObject)
    {
        if let match = GameFileManager.loadMatch(.SinglePlayer)
        {
            Match.shared = match
            let _ = GameFileManager.deleteGame("singlePlayer")
        }
        MainViewController.shared?.performSegue(withIdentifier: "playIdentifier", sender: nil)
    }
    
    @IBAction func changeDiceMaterial(_ sender: AnyObject)
    {
        let diceMats = PlayerStat.shared.ownedDiceMaterials()
        diceMatSelected = (diceMatSelected+1)%diceMats.count
        let diceMat = diceMats[diceMatSelected]
        diceTextureBtn?.setImage(diceMat.iconForValue(1), for: UIControlState())
    }
    
    @IBAction func playNewGame(_ sender: AnyObject)
    {
        let playerId = PlayerStat.shared.id
        let playerAlias = PlayerStat.shared.alias
        let avgScore6 = PlayerStat.avgScore(.six)
        let diceMat = PlayerStat.shared.ownedDiceMaterials()[diceMatSelected]
        Match.shared.start(.SinglePlayer,
                           diceNum: Match.shared.diceNum,
                           playersDesc: [(playerId,playerAlias,avgScore6,diceMat)],
                           matchId: 0,
                           bet: 0)
        MainViewController.shared?.performSegue(withIdentifier: "playIdentifier", sender: nil)
    }

    @IBAction func back(_ sender: AnyObject) {
        let _ = navigationController?.popViewController(animated: true)
    }
}
