//
//  LoginViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 16/12/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = FBSDKAccessToken.currentAccessToken()
        {
            performSegueWithIdentifier("next", sender: self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject)
    {
        let fbLogin = FBSDKLoginManager()
        fbLogin.logInWithReadPermissions(["public_profile","email","user_friends"],
                                         fromViewController: self)
        { (result, error) in
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
                self.performSegueWithIdentifier("next", sender: self)
            }
        }
    }

    @IBAction func playAsGuest(sender: AnyObject)
    {
        performSegueWithIdentifier("next", sender: self)
    }
    

}
