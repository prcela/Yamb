//
//  PrepareMPViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 24/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PrepareMPViewController: UIViewController {

    @IBOutlet weak var bacBtn: UIButton!
    @IBOutlet weak var dice56Btn: UIButton!
    @IBOutlet weak var diceTexBtnFirst: UIButton!
    @IBOutlet weak var diceTexBtnSecond: UIButton!
    @IBOutlet weak var createMatchBtn: UIButton!
    @IBOutlet weak var waitingLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var freePlayersLbl: UILabel!
    
    var diceNum: DiceNum = .Six
    var selectedDiceMats = [2,3]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFreePlayersCount), name: NotificationName.onRoomInfo, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bacBtn.setTitle(lstr("Back"), forState: .Normal)
        createMatchBtn.setTitle(lstr("Start match"), forState: .Normal)
        waitingLbl.text = lstr("Waiting for opponent player...")
        
        for btn in [diceTexBtnFirst,diceTexBtnSecond]
        {
            btn.layer.cornerRadius = 5
            btn.layer.borderColor = UIColor.lightGrayColor().CGColor
            btn.layer.borderWidth = 1
            btn.clipsToBounds = true
        }
        
        updateDiceBtn()
        updateFreePlayersCount()
    }
    
    func updateDiceBtn()
    {
        let title = lstr("Dice 5/6")
        let thinFont = UIFont.systemFontOfSize(30, weight: UIFontWeightThin)
        let defaultFont = UIFont.systemFontOfSize(30)
        
        let attrString = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.blackColor()
            ])
        
        let attrStringDisabled = NSMutableAttributedString(string: title, attributes: [
            NSFontAttributeName:thinFont,
            NSForegroundColorAttributeName:UIColor.grayColor()
            ])
        
        let loc = title.characters.indexOf(diceNum == .Five ? "5":"6")!
        
        attrString.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.startIndex.distanceTo(loc), 1))
        
        attrStringDisabled.addAttribute(NSFontAttributeName, value:defaultFont, range: NSMakeRange(title.startIndex.distanceTo(loc), 1))
        
        dice56Btn?.setAttributedTitle(attrString, forState: .Normal)
        
        dice56Btn.setAttributedTitle(attrStringDisabled, forState: .Disabled)
        
        let btns = [diceTexBtnFirst,diceTexBtnSecond]
        
        for (idx,matIdx) in selectedDiceMats.enumerate()
        {
            let current = diceMats[matIdx]
            btns[idx].setImage(UIImage(named: "1\(current.rawValue)"), forState: .Normal)
        }
    }
    
    func updateFreePlayersCount()
    {
        freePlayersLbl.text = lstr("Free players") + ": \(Room.main.freePlayers.count)"
    }
    
    
    @IBAction func back(sender: AnyObject)
    {
        // TODO: leave all my matches
        let playerId = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerId)!
        for matchInfo in Room.main.matchesInfo(playerId)
        {
            WsAPI.shared.leaveMatch(matchInfo.id)
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func toggleDiceCount(sender: UIButton) {
        diceNum = diceNum == .Five ? .Six : .Five
        updateDiceBtn()
    }
    
    @IBAction func changeFirstDiceMaterial(sender: AnyObject) {
        selectedDiceMats[0] = (selectedDiceMats[0]+1)%diceMats.count
        let diceMat = diceMats[selectedDiceMats[0]]
        diceTexBtnFirst.setImage(UIImage(named: "1\(diceMat.rawValue)"), forState: .Normal)
    }
    
    @IBAction func changeSecondDiceMAterial(sender: AnyObject) {
        
        selectedDiceMats[1] = (selectedDiceMats[1]+1)%diceMats.count
        let diceMat = diceMats[selectedDiceMats[1]]
        diceTexBtnSecond.setImage(UIImage(named: "1\(diceMat.rawValue)"), forState: .Normal)
    }
    
    @IBAction func createMatch(sender: UIButton) {
        sender.hidden = true
        dice56Btn.enabled = false
        diceTexBtnFirst.enabled = false
        diceTexBtnSecond.enabled = false
        waitingLbl.hidden = false
        activityIndicator.startAnimating()
        freePlayersLbl.hidden = false
        
        WsAPI.shared.createMatch(diceNum, diceMaterials: selectedDiceMats.map({ (idx) -> DiceMaterial in
            return diceMats[idx]
        }))
    }
}
