//
//  ScoresViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 13/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

class ScoresViewController: UIViewController
{
    
    private var allScores: [PlayerScore]?

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backBtn.setTitle(lstr("Back"), forState: .Normal)
        
        selectBtn.layer.borderWidth = 1
        selectBtn.layer.borderColor = UIColor(netHex: 0xaaaaaaaa).CGColor
        
        // proba ....
        ServerAPI.scores { (data, response, error) in
            let jsonAllScores = JSON(data: data!)
            guard !jsonAllScores.isEmpty else {return}
            self.allScores = [PlayerScore]()
            for json in jsonAllScores.array!
            {
                self.allScores?.append(PlayerScore(json: json))
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
        return allScores?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath)
        return cell
    }
}

extension ScoresViewController: ScorePickerDelegate
{
    func doneWithSelekcija(selekcija: ScorePickerSelekcija) {
        pickerContainerView.hidden = true
    }
}
