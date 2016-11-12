//
//  PurchaseViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 12/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class PurchaseViewController: UIViewController {

    @IBOutlet weak var holderView: UIView?
    @IBOutlet weak var descriptionLbl: UILabel?
    @IBOutlet weak var cancelBtn: UIButton?
    @IBOutlet weak var continueBtn: UIButton?
    @IBOutlet weak var priceLbl: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey(Prefs.playerAlias)!
        descriptionLbl?.text = String(format: lstr("Purchase description"), name)
        cancelBtn?.setTitle(lstr("Cancel"), forState: .Normal)
        continueBtn?.setTitle(lstr("Continue"), forState: .Normal)
        
        holderView?.layer.cornerRadius = 10
        holderView?.clipsToBounds = true
        
        updatePrice()
        
    }

    func updatePrice()
    {
        if let idx = retrievedProducts?.indexOf({product in
            return product.productIdentifier == purchaseNameId
        }) {
            let product = retrievedProducts![idx]
            let numberFormatter = NSNumberFormatter()
            numberFormatter.locale = product.priceLocale
            numberFormatter.numberStyle = .CurrencyStyle
            let priceString = numberFormatter.stringFromNumber(product.price ?? 0) ?? ""
            priceLbl?.text = "\(product.localizedTitle) \(priceString)"
        }
        else
        {
            priceLbl?.text = nil
        }
    }
    
    @IBAction func cancel(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func continuePurchase(sender: AnyObject)
    {
        dismissViewControllerAnimated(true) {
            SwiftyStoreKit.purchaseProduct(purchaseNameId) { result in
                switch result {
                case .Success(let productId):
                    print("Purchase Success: \(productId)")
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Stat saved")
                        PlayerStat.shared.purchasedName = true
                        PlayerStat.saveStat()
                    })
                    
                case .Error(let error):
                    print("Purchase Failed: \(error)")
                }
            }
        }
    }
    
    

}
