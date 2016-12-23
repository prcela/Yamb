//
//  PurchaseViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 12/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import Crashlytics

class PurchaseViewController: UIViewController {

    @IBOutlet weak var holderView: UIView?
    @IBOutlet weak var descriptionLbl: UILabel?
    @IBOutlet weak var cancelBtn: UIButton?
    @IBOutlet weak var continueBtn: UIButton?
    @IBOutlet weak var priceLbl: UILabel?
    @IBOutlet weak var restoreBtn: UIButton?
    @IBOutlet weak var icon: UIImageView?
    
    var descriptionText: String?
    var productId: String!
    fileprivate var product: SKProduct?
    var onPurchaseSuccess: (() -> Void)!
    var iconName: String?
    var itemName: String?
    var itemType: String?
    fileprivate var currencyCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        descriptionLbl?.text = descriptionText
        cancelBtn?.setTitle(lstr("Cancel"), for: UIControlState())
        continueBtn?.setTitle(lstr("Continue"), for: UIControlState())
        restoreBtn?.setTitle(lstr("Restore previous purchases"), for: UIControlState())
        
        holderView?.layer.cornerRadius = 10
        holderView?.clipsToBounds = true
        
        if iconName != nil
        {
            icon?.image = UIImage(named: iconName!)
            icon?.layer.cornerRadius = 10
            icon?.clipsToBounds = true
            icon?.layer.borderWidth = 0.5
            icon?.layer.borderColor = UIColor(netHex: 0x11111111).cgColor
        }
        
        updatePrice()
        
    }

    func updatePrice()
    {
        if let idx = retrievedProducts?.index(where: {product in
            return product.productIdentifier == productId
        }) {
            product = retrievedProducts![idx]
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = product!.priceLocale
            numberFormatter.numberStyle = .currency
            let priceString = numberFormatter.string(from: product!.price ) ?? ""
            priceLbl?.text = "\(product!.localizedTitle) \(priceString)"
            currencyCode = numberFormatter.currencyCode
        }
        else
        {
            priceLbl?.text = nil
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continuePurchase(_ sender: AnyObject)
    {
        dismiss(animated: true) {
            SwiftyStoreKit.purchaseProduct(self.productId) { result in
                switch result {
                case .success(let product):
                    print("Purchase Success: \(product.productId)")
                    DispatchQueue.main.async(execute: {
                        self.onPurchaseSuccess()
                        
                        guard self.product != nil else {return}
                        Answers.logPurchase(withPrice: self.product?.price,
                            currency: self.currencyCode,
                            success: true,
                            itemName: self.itemName,
                            itemType: self.itemType,
                            itemId: product.productId,
                            customAttributes: [:])
                    })
                    
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
    }
    
    @IBAction func restore(_ sender: AnyObject)
    {
        dismiss(animated: true) {
            SwiftyStoreKit.restorePurchases() { results in
                if results.restoreFailedProducts.count > 0 {
                    print("Restore Failed: \(results.restoreFailedProducts)")
                    
                    dispatchToMainQueue(delay: 1) {
                        let alertInfo = UIAlertController(title: "Yamb", message: lstr("Your purchase could not be restored."), preferredStyle: .alert)
                        alertInfo.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.present(alertInfo, animated: true, completion: nil)
                    }
                }
                else if results.restoredProducts.count > 0 {
                    print("Restore Success")
                    dispatchToMainQueue(delay: 1) {
                        self.onPurchaseSuccess()
                        
                        let alertInfo = UIAlertController(title: "Yamb", message: lstr("Purchases are successfully restored."), preferredStyle: .alert)
                        alertInfo.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.present(alertInfo, animated: true, completion: nil)
                    }
                }
                else {
                    print("Nothing to Restore")
                    
                    dispatchToMainQueue(delay: 1) {
                        let alertInfo = UIAlertController(title: "Yamb", message: lstr("You did not purshase anything before."), preferredStyle: .alert)
                        alertInfo.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        (MainViewController.shared?.presentedViewController ?? MainViewController.shared)?.present(alertInfo, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    

}
