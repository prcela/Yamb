//
//  PlayerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import Firebase

class PlayerViewController: UIViewController {

    @IBOutlet weak var statsBtn: UnderlineButton!
    @IBOutlet weak var diceBtn: UnderlineButton!
    @IBOutlet weak var dieIcon: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var playerNameLbl: UILabel!

    weak var playerContainer: PlayerContainer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(onFavDieSet), name: NotificationName.playerFavDiceChanged, object: nil)
        nc.addObserver(self, selector: #selector(onWantsNewDiceMat(_:)), name: NotificationName.wantsUnownedDiceMaterial, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editBtn.layer.borderWidth = 1
        editBtn.layer.cornerRadius = 5
        editBtn.layer.borderColor = UIColor.lightTextColor().CGColor
        
        playerNameLbl.text = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerAlias)
        editBtn.setTitle(lstr("Edit"), forState: .Normal)
        
        dieIcon.layer.borderWidth = 1
        dieIcon.layer.cornerRadius = 5
        dieIcon.layer.borderColor = UIColor.darkGrayColor().CGColor
        dieIcon.clipsToBounds = true
        
        dieIcon.image = PlayerStat.shared.favDiceMat.iconForValue(1)
        
        showStats(statsBtn)
        
    }
    
    func onFavDieSet()
    {
        dieIcon.image = PlayerStat.shared.favDiceMat.iconForValue(1)
    }
    
    func onWantsNewDiceMat(notification: NSNotification)
    {
        let diceMat = DiceMaterial(rawValue: notification.object as! String)!
        if DiceMaterial.forBuy().contains(diceMat)
        {
            performSegueWithIdentifier("purchaseDice", sender: notification.object)
        }
        else if DiceMaterial.forDiamonds().contains(diceMat)
        {
            if PlayerStat.shared.diamonds >= DiceMaterial.diamondsPrice()
            {
                let alert = UIAlertController(title: "Yamb", message: String(format: lstr("Buy dice for 💎" ), DiceMaterial.diamondsPrice()), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                    PlayerStat.shared.diamonds -= DiceMaterial.diamondsPrice()
                    PlayerStat.shared.boughtDiceMaterials.append(diceMat)
                    PlayerStat.saveStat()
                }))
                presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                suggestRewardVideo()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "embed"
        {
            playerContainer = segue.destinationViewController as? PlayerContainer
        }
        else if segue.identifier == "invitation"
        {
            let invitationVC = segue.destinationViewController as! InvitationViewController
            invitationVC.senderPlayer = sender as? Player
        }
        else if segue.identifier == "purchaseName"
        {
            let purchaseVC = segue.destinationViewController as! PurchaseViewController
            purchaseVC.descriptionText = lstr("Purchase description")
            purchaseVC.productId = purchaseNameId
            purchaseVC.onPurchaseSuccess = {
                PlayerStat.shared.purchasedName = true
                PlayerStat.saveStat()
            }
        }
        else if segue.identifier == "purchaseDice"
        {
            let diceMat = DiceMaterial(rawValue: sender as! String)!
            let purchaseVC = segue.destinationViewController as! PurchaseViewController
            purchaseVC.descriptionText = lstr("Purchase dice description")
            purchaseVC.productId = "yamb.PurchaseDice." + diceMat.rawValue
            purchaseVC.iconName = "1\(diceMat.rawValue)"
            purchaseVC.onPurchaseSuccess = {
                if !PlayerStat.shared.boughtDiceMaterials.contains(diceMat)
                {
                    PlayerStat.shared.boughtDiceMaterials.append(diceMat)
                }
                PlayerStat.saveStat()
            }
        }
    }

    @IBAction func showStats(sender: AnyObject)
    {
        statsBtn.selected = true
        diceBtn.selected = false
        dieIcon.alpha = 0.5
        playerContainer?.selectByName("Stat", completion: nil)
    }
    
    @IBAction func showDice(sender: AnyObject)
    {
        statsBtn.selected = false
        diceBtn.selected = true
        dieIcon.alpha = 1
        playerContainer?.selectByName("Dice", completion: nil)
    }
    
    @IBAction func close(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editName(sender: AnyObject)
    {
        let purchaseNameRequired = FIRRemoteConfig.remoteConfig()["purchase_name"].boolValue
        
        if PlayerStat.shared.purchasedName || !purchaseNameRequired
        {
            editNameInPopup()
        }
        else
        {
            performSegueWithIdentifier("purchaseName", sender: nil)
        }
        
    }
    
    func editNameInPopup()
    {
        let alert = UIAlertController(title: "Yamb", message: lstr("Input your name"), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            let alias = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerAlias)
            textField.text = alias
            textField.placeholder = lstr("Name")
        }
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            if let newAlias = alert.textFields?.first?.text
            {
                NSUserDefaults.standardUserDefaults().setObject(newAlias, forKey: Prefs.playerAlias)
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.playerAliasChanged, object: nil)
                self.playerNameLbl.text = newAlias
                ServerAPI.updatePlayer({ (_, _, _) in
                })
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
