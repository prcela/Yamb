//
//  PlayerContainer.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class PlayerContainer: ContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let profileViewController = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController")
        let statTableViewController = storyboard!.instantiateViewController(withIdentifier: "StatTableViewController")
        let diceContainer = storyboard!.instantiateViewController(withIdentifier: "DiceCollectionViewController")
        
        items = [
            ContainerItem(vc:profileViewController, name: "Profile"),
            ContainerItem(vc:statTableViewController, name: "Stat"),
            ContainerItem(vc:diceContainer, name: "Dice")
        ]
        selectByIndex(0)
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
