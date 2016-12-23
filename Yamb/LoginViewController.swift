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
        if let _ = FBSDKAccessToken.current()
        {
            performSegue(withIdentifier: "next", sender: self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginWithFacebook(_ sender: AnyObject)
    {
        let fbLogin = FBSDKLoginManager()
        fbLogin.logIn(withReadPermissions: ["public_profile","email","user_friends"],
                                         from: self)
        { (result, error) in
            if error != nil
            {
                print(error!)
            }
            else if (result?.isCancelled)!
            {
                print("Cancelled")
            }
            else
            {
                print("Logged in")
                self.performSegue(withIdentifier: "next", sender: self)
            }
        }
    }

    @IBAction func playAsGuest(_ sender: AnyObject)
    {
        performSegue(withIdentifier: "next", sender: self)
    }
    

}
