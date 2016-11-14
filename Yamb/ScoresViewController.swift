//
//  ScoresViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 13/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class ScoresViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backBtn.setTitle(lstr("Back"), forState: .Normal)
        
        // proba ....
        ServerAPI.scores { (data, response, error) in
            let json = JSON(data: data!)
            print(json)
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
    
    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }

}
