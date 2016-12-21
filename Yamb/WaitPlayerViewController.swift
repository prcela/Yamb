//
//  WaitPlayerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 06/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class WaitPlayerViewController: UIViewController {

    @IBOutlet weak var holderView: UIView?
    @IBOutlet weak var messageLbl: UILabel?
    @IBOutlet weak var counterLbl: UILabel?
    
    var waitPlayer: Player!
    var ctSecs = 10
    var timer: Timer?
    var timout: (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onRoomInfo), name: NotificationName.onRoomInfo, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        holderView!.layer.cornerRadius = 10
        holderView!.clipsToBounds = true
        
        messageLbl!.text = String(format:  lstr("Waiting for player"), waitPlayer.alias!)
        counterLbl!.text = "\(ctSecs)s"
    }

    func onTimer()
    {
        ctSecs -= 1
        counterLbl?.text = "\(ctSecs)s"
        
        if ctSecs == 0
        {
            timer?.invalidate()
            timer = nil
            dismiss(animated: true, completion: timout)
        }
    }
    
    func onRoomInfo()
    {
        if let player = Room.main.player(waitPlayer.id!)
        {
            if player.connected
            {
                dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            // nema igrača, isto kao i timeout
            timer?.invalidate()
            timer = nil
            dismiss(animated: true, completion: timout)
        }
        
    }
    


}
