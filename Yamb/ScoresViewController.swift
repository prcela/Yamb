//
//  ScoresViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 13/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

var scoreSelekcija = ScorePickerSelekcija()

class ScoresViewController: UIViewController
{
    
    private var allPlayers: [PlayerInfo]?
    private var allStatItems: [StatItem]?

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backBtn.setTitle(lstr("Back"), forState: .Normal)
        
        selectBtn.layer.borderWidth = 1
        selectBtn.layer.borderColor = UIColor(netHex: 0xaaaaaaaa).CGColor
        
        // proba .... get all players
        ServerAPI.players { [weak self] (data, response, error) in
            self?.allPlayers = [PlayerInfo]()
            guard data != nil && error == nil
                else {return}
            
            let jsonPlayers = JSON(data: data!)
            guard !jsonPlayers.isEmpty else {return}
            for json in jsonPlayers.array!
            {
                self?.allPlayers?.append(PlayerInfo(json: json))
            }
        }
        
        ServerAPI.statItems { [weak self] (data, response, error) in
            self?.allStatItems = [StatItem]()
            
            guard data != nil && error == nil
                else {return}
            
            let jsonItems = JSON(data: data!)
            guard !jsonItems.isEmpty else {return}
            for json in jsonItems.array!
            {
                self?.allStatItems?.append(StatItem(json: json))
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedPicker"
        {
            let scorePickerVC = segue.destinationViewController as! ScorePickerViewController
            scorePickerVC.scorePickerDelegate = self
            
        }
    }

    
    @IBAction func back(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showPicker(sender: AnyObject)
    {
        pickerContainerView.hidden = false
    }
    

}

extension ScoresViewController: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayers?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath)
        return cell
    }
}

extension ScoresViewController: ScorePickerDelegate
{
    func doneWithSelekcija() {
        pickerContainerView.hidden = true
    }
}
