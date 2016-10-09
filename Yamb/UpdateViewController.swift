//
//  UpdateViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 06/10/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {

    @IBOutlet weak var holderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        holderView.layer.cornerRadius = 10
        
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
    @IBAction func update(sender: AnyObject)
    {
        let url = NSURL(string: "https://itunes.apple.com/hr/app/yamb/id354188615?mt=8")!
        UIApplication.sharedApplication().openURL(url)
    }

    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
}
