//
//  ScorePickerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 15/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

enum ScoreType: Int
{
    case FiveDice = 0
    case SixDice
    case Diamonds
    
    func title() -> String
    {
        switch self {
        case .FiveDice:
            return "5 🎲"
        case .SixDice:
            return "6 🎲"
        case .Diamonds:
            return "💎"
        }
    }
}

enum ScoreValue: Int
{
    case Score = 0
    case Stars
    case Gc
    
    func title() -> String
    {
        switch self {
        case .Score:
            return lstr("Score")
        case .Stars:
            return "⭐️"
        case .Gc:
            return "Game center"
        }
    }
}

enum ScoreTimeRange: Int
{
    case Now = -1
    case Ever = 0
    case Week
    case Today
}

struct ScorePickerSelekcija
{
    var scoreType: ScoreType = .SixDice
    var scoreValue: ScoreValue = .Score
    var timeRange: ScoreTimeRange = .Ever
}

protocol ScorePickerDelegate: class
{
    func doneWithSelekcija()
}

class ScorePickerViewController: UIViewController
{
    weak var scorePickerDelegate:ScorePickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func done(sender: AnyObject)
    {
        scorePickerDelegate?.doneWithSelekcija()
    }
}

extension ScorePickerViewController: UIPickerViewDataSource
{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0
        {
            return 3
        }
        else
        {
            if scoreSelekcija.scoreType == .Diamonds
            {
                return 1
            }
            else
            {
                return 3
            }
        }
    }
}

extension ScorePickerViewController: UIPickerViewDelegate
{
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0
        {
            return ScoreType(rawValue: row)!.title()
        }
        else
        {
            if scoreSelekcija.scoreType == .Diamonds
            {
                return lstr("Now")
            }
            else
            {
                return ScoreValue(rawValue: row)!.title()
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(row) \(component)")
        if component == 0
        {
            scoreSelekcija.scoreType = ScoreType(rawValue: row)!
            pickerView.reloadComponent(1)
        }
        else
        {
            if scoreSelekcija.scoreType == .Diamonds
            {
                scoreSelekcija.timeRange = .Now
            }
            else
            {
                scoreSelekcija.timeRange = ScoreTimeRange(rawValue: row)!
            }
            
        }
    }
}
