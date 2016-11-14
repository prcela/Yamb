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
    @IBOutlet weak var restoreBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        descriptionLbl?.text = lstr("Purchase description")
        cancelBtn?.setTitle(lstr("Cancel"), forState: .Normal)
        continueBtn?.setTitle(lstr("Continue"), forState: .Normal)
        restoreBtn.setTitle(lstr("Restore previous purchases"), forState: .Normal)
        
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
    
    @IBAction func restore(sender: AnyObject)
    {
        dismissViewControllerAnimated(true) {
            SwiftyStoreKit.restorePurchases() { results in
                if results.restoreFailedProducts.count > 0 {
                    print("Restore Failed: \(results.restoreFailedProducts)")
                    
                    dispatchToMainQueue(delay: 1) {
                        let alertInfo = UIAlertController(title: "Yamb", message: lstr("Your purchase could not be restored."), preferredStyle: .Alert)
                        alertInfo.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.presentViewController(alertInfo, animated: true, completion: nil)
                    }
                }
                else if results.restoredProductIds.count > 0 {
                    print("Restore Success: \(results.restoredProductIds)")
                    dispatchToMainQueue(delay: 1) {
                        PlayerStat.shared.purchasedName = true
                        PlayerStat.saveStat()
                        
                        let alertInfo = UIAlertController(title: "Yamb", message: lstr("Purchases are successfully restored."), preferredStyle: .Alert)
                        alertInfo.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.presentViewController(alertInfo, animated: true, completion: nil)
                    }
                }
                else {
                    print("Nothing to Restore")
                    
                    dispatchToMainQueue(delay: 1) {
                        let alertInfo = UIAlertController(title: "Yamb", message: lstr("You did not purshase anything before."), preferredStyle: .Alert)
                        alertInfo.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.presentViewController(alertInfo, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    

}
