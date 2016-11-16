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

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var playerNameLbl: UILabel!
    @IBOutlet weak var favDiceLbl: UILabel!
    @IBOutlet weak var favDiceBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        editBtn.layer.borderWidth = 1
        editBtn.layer.cornerRadius = 5
        editBtn.layer.borderColor = UIColor.lightTextColor().CGColor
        
        playerNameLbl.text = NSUserDefaults.standardUserDefaults().stringForKey(Prefs.playerAlias)
        editBtn.setTitle(lstr("Edit"), forState: .Normal)
        
        favDiceLbl.text = lstr("Favorite dice")
        favDiceBtn.layer.borderWidth = 1
        favDiceBtn.layer.cornerRadius = 5
        favDiceBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        favDiceBtn.clipsToBounds = true
        
        favDiceBtn.setImage(UIImage(named: "1\(PlayerStat.shared.favDiceMat.rawValue)"), forState: .Normal)
        
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
    
    @IBAction func toggleFavDice(sender: AnyObject)
    {
        let diceMats = allDiceMaterials()
        if let idx = diceMats.indexOf(PlayerStat.shared.favDiceMat)
        {
            PlayerStat.shared.favDiceMat = diceMats[(idx+1)%diceMats.count]
            favDiceBtn.setImage(UIImage(named: "1\(PlayerStat.shared.favDiceMat.rawValue)"), forState: .Normal)
        }
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
            performSegueWithIdentifier("purchase", sender: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "invitation"
        {
            let invitationVC = segue.destinationViewController as! InvitationViewController
            invitationVC.senderPlayer = sender as? Player
        }
    }
}
