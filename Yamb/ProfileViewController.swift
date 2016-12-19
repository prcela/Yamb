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

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var playerNameLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editBtn.layer.borderWidth = 1
        editBtn.layer.cornerRadius = 5
        editBtn.layer.borderColor = UIColor.lightTextColor().CGColor
        
        playerNameLbl.text = PlayerStat.shared.alias
        editBtn.setTitle(lstr("Edit"), forState: .Normal)

        
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
    

    @IBAction func logout(sender: AnyObject)
    {
        FBSDKLoginManager().logOut()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
