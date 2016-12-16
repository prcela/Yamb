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
            }
        }
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
