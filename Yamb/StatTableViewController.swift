//
//  StatTableViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 03/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class StatTableViewController: UIViewController {

    @IBOutlet weak var statsTableView: StatsTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        statsTableView.playerStat = PlayerStat.shared
        statsTableView.refreshStat()
    }

    override func viewDidLayoutSubviews() {
        statsTableView.updateFrames()
    }

}
