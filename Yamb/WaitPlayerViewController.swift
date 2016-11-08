//
//  WaitPlayerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 06/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class WaitPlayerViewController: UIViewController {

    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var counterLbl: UILabel!
    
    var waitPlayer: Player!
    var ctSecs = 10
    var timer: NSTimer?
    var timout: (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onRoomInfo), name: NotificationName.onRoomInfo, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        holderView.layer.cornerRadius = 10
        holderView.clipsToBounds = true
        
        messageLbl.text = String(format:  lstr("Waiting for player"), waitPlayer.alias!)
        counterLbl.text = "\(ctSecs)s"
    }

    func onTimer()
    {
        ctSecs -= 1
        counterLbl.text = "\(ctSecs)s"
        
        if ctSecs == 0
        {
            timer?.invalidate()
            timer = nil
            dismissViewControllerAnimated(true, completion: timout)
        }
    }
    
    func onRoomInfo()
    {
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
