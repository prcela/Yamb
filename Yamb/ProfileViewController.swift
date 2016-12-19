//
//  ProfileViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 16/12/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseRemoteConfig
import SwiftyStoreKit
import Crashlytics

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var playerNameLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var dice5StarsLbl: UILabel!
    @IBOutlet weak var dice6StarsLbl: UILabel!
    @IBOutlet weak var diamondsLbl: UILabel!
    @IBOutlet weak var buyDiamondsBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var connectFbBtn: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateDiamonds), name: NotificationName.playerDiamondsChanged, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for view in [editBtn, buyDiamondsBtn, logoutBtn, connectFbBtn]
        {
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor.lightTextColor().CGColor
        }
        
        playerNameLbl.text = PlayerStat.shared.alias
        editBtn.setTitle(lstr("Edit"), forState: .Normal)
        logoutBtn.setTitle(lstr("Logout"), forState: .Normal)
        connectFbBtn.setTitle(lstr("Connect with Facebook"), forState: .Normal)

        diamondsLbl.text = "\(PlayerStat.shared.diamonds) 💎"
        
        let myStars5 = stars5(PlayerStat.avgScore(.Five))
        let myStars6 = stars6(PlayerStat.avgScore(.Six))
        
        dice5StarsLbl.text = String(format: "5 🎲 %@ ⭐️", starsFormatter.stringFromNumber(NSNumber(float: myStars5))!)
        dice6StarsLbl.text = String(format: "6 🎲 %@ ⭐️", starsFormatter.stringFromNumber(NSNumber(float: myStars6))!)
        
        let diamondsQuantity = FIRRemoteConfig.remoteConfig()["purchase_diamonds_quantity"].numberValue!.integerValue
        
        if let idx = retrievedProducts?.indexOf({product in
            return product.productIdentifier == purchaseDiamondsId
        }) {
            let product = retrievedProducts![idx]
            let numberFormatter = NSNumberFormatter()
            numberFormatter.locale = product.priceLocale
            numberFormatter.numberStyle = .CurrencyStyle
            let priceString = numberFormatter.stringFromNumber(product.price ?? 0) ?? ""
            buyDiamondsBtn.setTitle("+\(diamondsQuantity) 💎 \(priceString)", forState: .Normal)
        }
        else
        {
            buyDiamondsBtn.setTitle("+\(diamondsQuantity) 💎", forState: .Normal)
        }
        
        let fbToken = FBSDKAccessToken.currentAccessToken()
        
        connectFbBtn.hidden = (fbToken != nil)
        logoutBtn.hidden = (fbToken == nil)
        
    }
    
    func updateDiamonds()
    {
        diamondsLbl.text = "\(PlayerStat.shared.diamonds) 💎"
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
            let alias = PlayerStat.shared.alias
            textField.text = alias
            textField.placeholder = lstr("Name")
        }
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            if let newAlias = alert.textFields?.first?.text
            {
                PlayerStat.shared.alias = newAlias
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.playerAliasChanged, object: nil)
                self.playerNameLbl.text = newAlias
                ServerAPI.updatePlayer({ (_, _, _) in
                })
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func buyDiamonds(sender: AnyObject)
    {
        SwiftyStoreKit.purchaseProduct(purchaseDiamondsId) { result in
            switch result {
            case .Success(let productId):
                print("Purchase Success: \(productId)")
                dispatch_async(dispatch_get_main_queue(), {
        
                    let diamondsQuantity = FIRRemoteConfig.remoteConfig()["purchase_diamonds_quantity"].numberValue!.integerValue
                    PlayerStat.shared.diamonds += diamondsQuantity
                    PlayerStat.saveStat()
                    
                    if let idx = retrievedProducts?.indexOf({product in
                        return product.productIdentifier == productId
                    }) {
                        let product = retrievedProducts![idx]
                        let numberFormatter = NSNumberFormatter()
                        numberFormatter.locale = product.priceLocale
                        numberFormatter.numberStyle = .CurrencyStyle
                        let currencyCode = numberFormatter.currencyCode
                    
                    Answers.logPurchaseWithPrice(product.price,
                        currency: currencyCode,
                        success: true,
                        itemName: "Diamonds",
                        itemType: nil,
                        itemId: productId,
                        customAttributes: [:])
                    }})
                
            case .Error(let error):
                print("Purchase Failed: \(error)")
                
                dispatchToMainQueue(delay: 1) {
                    let alertInfo = UIAlertController(title: "Yamb", message: lstr("Purchase failed"), preferredStyle: .Alert)
                    alertInfo.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.presentViewController(alertInfo, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func connectFb(sender: AnyObject)
    {
        let fbLogin = FBSDKLoginManager()
        fbLogin.logInWithReadPermissions(["public_profile","email","user_friends"],
                                         fromViewController: self)
        { [weak self] (result, error) in
            if error != nil
            {
                print(error)
            }
            else if result.isCancelled
            {
                print("Cancelled")
            }
            else
            {
                print("Logged in")
                self?.connectFbBtn.hidden = true
                self?.logoutBtn.hidden = false
            }
        }
    }
    
    @IBAction func logout(sender: AnyObject)
    {
        FBSDKLoginManager().logOut()
        connectFbBtn.hidden = false
        logoutBtn.hidden = true
    }


}
