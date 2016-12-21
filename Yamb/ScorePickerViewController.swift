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
    case fiveDice = 0
    case sixDice
    case diamonds
    
    func title() -> String
    {
        switch self {
        case .fiveDice:
            return "5 🎲"
        case .sixDice:
            return "6 🎲"
        case .diamonds:
            return "💎"
        }
    }
}

enum ScoreValue: Int
{
    case score = 0
    case stars
    case gc
    
    func title() -> String
    {
        switch self {
        case .score:
            return lstr("Score")
        case .stars:
            return "⭐️"
        case .gc:
            return "Game center"
        }
    }
}

enum ScoreTimeRange: Int
{
    case now = -1
    case ever = 0
    case week
    case today
}

struct ScorePickerSelekcija
{
    var scoreType: ScoreType = .sixDice
    var scoreValue: ScoreValue = .score
    var timeRange: ScoreTimeRange = .ever
    
    func title() -> String
    {
        if scoreType == .diamonds
        {
            return "\(scoreType.title()) \(lstr("Now"))"
        }
        return "\(scoreType.title()) \(scoreValue.title())"
    }
}

protocol ScorePickerDelegate: class
{
    func doneWithSelekcija()
}

class ScorePickerViewController: UIViewController
{
    weak var scorePickerDelegate:ScorePickerDelegate?
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var doneBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        doneBtn.setTitle(lstr("Done"), for: UIControlState())
        // select current
        pickerView.selectRow(scoreSelekcija.scoreType.rawValue, inComponent: 0, animated: false)
        if scoreSelekcija.scoreType != .diamonds
        {
            pickerView.selectRow(scoreSelekcija.scoreValue.rawValue, inComponent: 1, animated: false)
        }
    }

    @IBAction func done(_ sender: AnyObject)
    {
        scorePickerDelegate?.doneWithSelekcija()
    }
}

extension ScorePickerViewController: UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0
        {
            return 3
        }
        else
        {
            if scoreSelekcija.scoreType == .diamonds
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0
        {
            return ScoreType(rawValue: row)!.title()
        }
        else
        {
            if scoreSelekcija.scoreType == .diamonds
            {
                return lstr("Now")
            }
            else
            {
                return ScoreValue(rawValue: row)!.title()
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(row) \(component)")
        if component == 0
        {
            // resetiraj ostale komponente
            let scoreTypeBefore = scoreSelekcija.scoreType
            scoreSelekcija.scoreType = ScoreType(rawValue: row)!
            if scoreSelekcija.scoreType == .diamonds
            {
                scoreSelekcija.scoreValue = .score
                scoreSelekcija.timeRange = .now
            }
            else if scoreSelekcija.timeRange == .now
            {
                scoreSelekcija.timeRange = .ever
            }
            
            if scoreTypeBefore == .diamonds
            {
                scoreSelekcija.scoreValue = .score
            }
            pickerView.reloadComponent(1)
        }
        else
        {
            scoreSelekcija.scoreValue = ScoreValue(rawValue: row)!
            if scoreSelekcija.scoreType == .diamonds
            {
                scoreSelekcija.timeRange = .now
            }
            else
            {
                scoreSelekcija.scoreValue = ScoreValue(rawValue: row)!
                scoreSelekcija.timeRange = .ever
            }
            
        }
        print("\(scoreSelekcija.scoreType) \(scoreSelekcija.scoreValue) \(scoreSelekcija.timeRange)")
    }
}
