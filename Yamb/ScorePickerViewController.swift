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
    case Default=0
    case Stars
    case Diamonds
    case Gc
    
    func title() -> String
    {
        switch self {
        case .Default:
            return lstr("Score")
        case .Stars:
            return "⭐️"
        case .Diamonds:
            return "💎"
        default:
            return "GC"
        }
    }
}

enum ScoreTimeRange: Int
{
    case Ever=0
    case Week
    case Today
}

struct ScorePickerSelekcija
{
    var diceNum: DiceNum = .Six
    var scoreType: ScoreType = .Default
    var timeRange: ScoreTimeRange = .Ever
}

protocol ScorePickerDelegate: class
{
    func doneWithSelekcija(selekcija: ScorePickerSelekcija)
}

class ScorePickerViewController: UIViewController
{
    var selekcija = ScorePickerSelekcija()
    weak var scorePickerDelegate:ScorePickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func done(sender: AnyObject)
    {
        scorePickerDelegate?.doneWithSelekcija(selekcija)
    }
}

extension ScorePickerViewController: UIPickerViewDataSource
{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0
        {
            return 2
        }
        else if component == 1
        {
            return 4
        }
        else if selekcija.scoreType == .Gc
        {
            return 3
        }
        else
        {
            return 1
        }
    }
}

extension ScorePickerViewController: UIPickerViewDelegate
{
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0
        {
            return row == 0 ? "5 🎲" : "6 🎲"
        }
        else if component == 1
        {
            return ScoreType(rawValue: row)!.title()
        }
        else
        {
            return "\(ScoreTimeRange(rawValue: row)!)"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(row) \(component)")
        if component == 0
        {
            selekcija.diceNum = [.Five,.Six][row]
        }
        else if component == 1
        {
            selekcija.scoreType = ScoreType(rawValue: row)!
            pickerView.reloadComponent(2)
        }
        else
        {
            selekcija.timeRange = ScoreTimeRange(rawValue: row)!
        }
    }
}
