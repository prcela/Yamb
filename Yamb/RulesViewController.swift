//
//  RulesViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 28/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn?.setTitle(lstr("Back"), for: UIControlState())

        // Do any additional setup after loading the view.
        let lang = lstr("lang")
        let url = Bundle.main.url(forResource: "index_\(lang)", withExtension: "html", subdirectory: "rules")!
        webView.loadRequest(URLRequest(url: url))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: AnyObject)
    {
        let _ = navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
