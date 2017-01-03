//
//  PlayerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class PlayerViewController: UIViewController {

    @IBOutlet weak var profileBtn: UnderlineButton!
    @IBOutlet weak var statsBtn: UnderlineButton!
    @IBOutlet weak var diceBtn: UnderlineButton!
    @IBOutlet weak var dieIcon: UIImageView!

    weak var playerContainer: PlayerContainer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(onFavDieSet), name: .playerFavDiceChanged, object: nil)
        nc.addObserver(self, selector: #selector(onWantsNewDiceMat(_:)), name: .wantsUnownedDiceMaterial, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dieIcon.layer.borderWidth = 1
        dieIcon.layer.cornerRadius = 5
        dieIcon.layer.borderColor = UIColor.darkGray.cgColor
        dieIcon.clipsToBounds = true
        
        dieIcon.image = PlayerStat.shared.favDiceMat.iconForValue(1)
        profileBtn.setTitle(lstr("Profile"), for: UIControlState())
        
        showProfile(profileBtn)
        
    }
    
    func onFavDieSet()
    {
        dieIcon.image = PlayerStat.shared.favDiceMat.iconForValue(1)
    }
    
    func onWantsNewDiceMat(_ notification: Notification)
    {
        let diceMat = DiceMaterial(rawValue: notification.object as! String)!
        if DiceMaterial.forBuy.contains(diceMat)
        {
            performSegue(withIdentifier: "purchaseDice", sender: notification.object)
        }
        else if DiceMaterial.forDiamonds.contains(diceMat)
        {
            if PlayerStat.shared.diamonds >= DiceMaterial.diamondsPrice()
            {
                let alert = UIAlertController(title: "Yamb", message: String(format: lstr("Buy dice for 💎" ), DiceMaterial.diamondsPrice()), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    PlayerStat.shared.diamonds -= DiceMaterial.diamondsPrice()
                    PlayerStat.shared.boughtDiceMaterials.append(diceMat)
                    PlayerStat.saveStat()
                }))
                present(alert, animated: true, completion: nil)
            }
            else
            {
                suggestRewardVideo()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "embed"
        {
            playerContainer = segue.destination as? PlayerContainer
        }
        else if segue.identifier == "invitation"
        {
            let invitationVC = segue.destination as! InvitationViewController
            invitationVC.senderPlayer = sender as? Player
        }
        else if segue.identifier == "purchaseName"
        {
            let purchaseVC = segue.destination as! PurchaseViewController
            purchaseVC.descriptionText = lstr("Purchase description")
            purchaseVC.productId = purchaseNameId
            purchaseVC.itemType = "Name"
            purchaseVC.onPurchaseSuccess = {
                PlayerStat.shared.purchasedName = true
                PlayerStat.saveStat()
            }
        }
        else if segue.identifier == "purchaseDice"
        {
            let diceMat = DiceMaterial(rawValue: sender as! String)!
            let purchaseVC = segue.destination as! PurchaseViewController
            purchaseVC.descriptionText = lstr("Purchase dice description")
            purchaseVC.productId = "yamb.PurchaseDice." + diceMat.rawValue
            purchaseVC.iconName = "1\(diceMat.rawValue)"
            purchaseVC.itemType = "Dice"
            purchaseVC.onPurchaseSuccess = {
                if !PlayerStat.shared.boughtDiceMaterials.contains(diceMat)
                {
                    PlayerStat.shared.boughtDiceMaterials.append(diceMat)
                }
                PlayerStat.saveStat()
            }
        }
    }

    @IBAction func showProfile(_ sender: AnyObject)
    {
        profileBtn.isSelected = true
        statsBtn.isSelected = false
        diceBtn.isSelected = false
        dieIcon.alpha = 0.75
        let _ = playerContainer?.selectByName("Profile", completion: nil)
    }
    
    @IBAction func showStats(_ sender: AnyObject)
    {
        profileBtn.isSelected = false
        statsBtn.isSelected = true
        diceBtn.isSelected = false
        dieIcon.alpha = 0.75
        let _ = playerContainer?.selectByName("Stat", completion: nil)
    }
    
    @IBAction func showDice(_ sender: AnyObject)
    {
        profileBtn.isSelected = false
        statsBtn.isSelected = false
        diceBtn.isSelected = true
        dieIcon.alpha = 1
        let _ = playerContainer?.selectByName("Dice", completion: nil)
    }
    
    @IBAction func close(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }
    
}
