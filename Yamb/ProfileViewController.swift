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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDiamonds), name: NotificationName.playerDiamondsChanged, object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for view in [editBtn, buyDiamondsBtn, logoutBtn, connectFbBtn]
        {
            view?.layer.borderWidth = 1
            view?.layer.cornerRadius = 5
            view?.layer.borderColor = UIColor.lightText.cgColor
        }
        
        playerNameLbl.text = PlayerStat.shared.alias
        editBtn.setTitle(lstr("Edit"), for: UIControlState())
        logoutBtn.setTitle(lstr("Logout"), for: UIControlState())
        connectFbBtn.setTitle(lstr("Connect with Facebook"), for: UIControlState())

        diamondsLbl.text = "\(PlayerStat.shared.diamonds) 💎"
        
        let myStars5 = stars5(PlayerStat.avgScore(.five))
        let myStars6 = stars6(PlayerStat.avgScore(.six))
        
        dice5StarsLbl.text = String(format: "5 🎲 %@ ⭐️", starsFormatter.string(from: NSNumber(value: myStars5 as Float))!)
        dice6StarsLbl.text = String(format: "6 🎲 %@ ⭐️", starsFormatter.string(from: NSNumber(value: myStars6 as Float))!)
        
        let diamondsQuantity = FIRRemoteConfig.remoteConfig()["purchase_diamonds_quantity"].numberValue!.intValue
        
        if let idx = retrievedProducts?.index(where: {product in
            return product.productIdentifier == purchaseDiamondsId
        }) {
            let product = retrievedProducts![idx]
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = product.priceLocale
            numberFormatter.numberStyle = .currency
            let priceString = numberFormatter.string(from: product.price ?? 0) ?? ""
            buyDiamondsBtn.setTitle("+\(diamondsQuantity) 💎 \(priceString)", for: UIControlState())
        }
        else
        {
            buyDiamondsBtn.setTitle("+\(diamondsQuantity) 💎", for: UIControlState())
        }
        
        let fbToken = FBSDKAccessToken.current()
        
        connectFbBtn.isHidden = (fbToken != nil)
        logoutBtn.isHidden = (fbToken == nil)
        
    }
    
    func updateDiamonds()
    {
        diamondsLbl.text = "\(PlayerStat.shared.diamonds) 💎"
    }
    
    @IBAction func editName(_ sender: AnyObject)
    {
        let purchaseNameRequired = FIRRemoteConfig.remoteConfig()["purchase_name"].boolValue
        
        if PlayerStat.shared.purchasedName || !purchaseNameRequired
        {
            editNameInPopup()
        }
        else
        {
            performSegue(withIdentifier: "purchaseName", sender: nil)
        }
        
    }
    
    func editNameInPopup()
    {
        let alert = UIAlertController(title: "Yamb", message: lstr("Input your name"), preferredStyle: .alert)
        alert.addTextField { (textField) in
            let alias = PlayerStat.shared.alias
            textField.text = alias
            textField.placeholder = lstr("Name")
        }
        alert.addAction(UIAlertAction(title: lstr("Cancel"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let newAlias = alert.textFields?.first?.text
            {
                PlayerStat.shared.alias = newAlias
                NotificationCenter.default.post(name: NotificationName.playerAliasChanged, object: nil)
                self.playerNameLbl.text = newAlias
                ServerAPI.updatePlayer({ (_, _, _) in
                })
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buyDiamonds(_ sender: AnyObject)
    {
        SwiftyStoreKit.purchaseProduct(purchaseDiamondsId) { result in
            switch result {
            case .success(let product):
                print("Purchase Success: \(product.productId)")
                DispatchQueue.main.async (execute: {
        
                    let diamondsQuantity = FIRRemoteConfig.remoteConfig()["purchase_diamonds_quantity"].numberValue!.intValue
                    PlayerStat.shared.diamonds += diamondsQuantity
                    PlayerStat.saveStat()
                    
                    if let idx = retrievedProducts?.index(where: {retProduct in
                        return retProduct.productIdentifier == product.productId
                    }) {
                        let product = retrievedProducts![idx]
                        let numberFormatter = NumberFormatter()
                        numberFormatter.locale = product.priceLocale
                        numberFormatter.numberStyle = .currency
                        let currencyCode = numberFormatter.currencyCode
                    
                        Answers.logPurchase(withPrice: product.price,
                                            currency: currencyCode,
                                            success: true,
                                            itemName: "Diamonds",
                                            itemType: nil,
                                            itemId: product.productIdentifier,
                                            customAttributes: [:])
                    }})
                
            case .error(let error):
                print("Purchase Failed: \(error)")
                
                dispatchToMainQueue(delay: 1) {
                    let alertInfo = UIAlertController(title: "Yamb", message: lstr("Purchase failed"), preferredStyle: .alert)
                    alertInfo.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.present(alertInfo, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func connectFb(_ sender: AnyObject)
    {
        let fbLogin = FBSDKLoginManager()
        fbLogin.logIn(withReadPermissions: ["public_profile","email","user_friends"],
                                         from: self)
        { [weak self] (result, error) in
            if error != nil
            {
                print(error)
            }
            else if (result?.isCancelled)!
            {
                print("Cancelled")
            }
            else
            {
                print("Logged in")
                self?.connectFbBtn.isHidden = true
                self?.logoutBtn.isHidden = false
            }
        }
    }
    
    @IBAction func logout(_ sender: AnyObject)
    {
        FBSDKLoginManager().logOut()
        connectFbBtn.isHidden = false
        logoutBtn.isHidden = true
    }


}
