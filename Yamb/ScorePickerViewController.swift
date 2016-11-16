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
    case FiveDice=0
    case SixDice
    case Gc
    case Stars
    case Diamonds
    
    func title() -> String
    {
        switch self {
        case .FiveDice:
            return "5 🎲"
        case .SixDice:
            return "6 🎲"
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
    case Now = -1
    case Ever = 0
    case Week
    case Today
}

struct ScorePickerSelekcija
{
    var scoreType: ScoreType = .SixDice
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
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0
        {
            return 5
        }
        else
        {
            if selekcija.scoreType == .Diamonds || selekcija.scoreType == .Stars
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
            if selekcija.scoreType == .Diamonds || selekcija.scoreType == .Stars
            {
                return lstr("Now")
            }
            else
            {
                return "\(ScoreTimeRange(rawValue: row)!)"
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(row) \(component)")
        if component == 0
        {
            selekcija.scoreType = ScoreType(rawValue: row)!
            pickerView.reloadComponent(1)
        }
        else
        {
            if selekcija.scoreType == .Diamonds || selekcija.scoreType == .Stars
            {
                selekcija.timeRange = .Now
            }
            else
            {
                selekcija.timeRange = ScoreTimeRange(rawValue: row)!
            }
            
        }
    }
}
