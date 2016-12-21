//
//  StatsTableView.swift
//  Yamb
//
//  Created by Kresimir Prcela on 04/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

private let ctColumns = 5
private let ctRows = 9

class StatsTableView: UIView
{
    var playerStat: PlayerStat?

    fileprivate func calculateCellSize() -> CGSize {
        let colWidth = round(frame.width/CGFloat(ctColumns)-0.5)
        let rowHeight = round(min(400,frame.height)/CGFloat(ctRows)-0.5)
        return CGSize(width: colWidth, height: rowHeight)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        let cellSize = calculateCellSize()
        
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        
        let connectedLines = [
            [TablePos(rowIdx: 0,colIdx: 2),TablePos(rowIdx: 0,colIdx: 5),TablePos(rowIdx:9, colIdx:5),TablePos(rowIdx:9,colIdx: 0),TablePos(rowIdx: 1,colIdx: 0)],
            [TablePos(rowIdx: 1,colIdx: 0),TablePos(rowIdx: 1,colIdx: 5)],
            [TablePos(rowIdx: 2,colIdx: 0),TablePos(rowIdx: 2,colIdx: 5)],
            [TablePos(rowIdx: 3,colIdx: 0),TablePos(rowIdx: 3,colIdx: 5)],
            [TablePos(rowIdx: 4,colIdx: 0),TablePos(rowIdx: 4,colIdx: 5)],
            [TablePos(rowIdx: 0,colIdx: 2),TablePos(rowIdx: 9,colIdx: 2)],
            [TablePos(rowIdx: 0,colIdx: 3),TablePos(rowIdx: 8,colIdx: 3)],
            [TablePos(rowIdx: 0,colIdx: 4),TablePos(rowIdx: 8,colIdx: 4)],
            [TablePos(rowIdx: 6,colIdx: 0),TablePos(rowIdx: 6,colIdx: 5)],
            [TablePos(rowIdx: 5,colIdx: 1),TablePos(rowIdx: 5,colIdx: 5)],
            [TablePos(rowIdx: 7,colIdx: 1),TablePos(rowIdx: 7,colIdx: 5)],
            [TablePos(rowIdx: 4,colIdx: 1),TablePos(rowIdx: 9,colIdx: 1)],
            [TablePos(rowIdx: 8,colIdx: 0),TablePos(rowIdx: 8,colIdx: 5)]
            ]
        
        for lines in connectedLines
        {
            for (idx,p) in lines.enumerated()
            {
                let x = CGFloat(p.colIdx)*cellSize.width
                let y = CGFloat(p.rowIdx)*cellSize.height
                
                if idx == 0
                {
                    ctx.beginPath()
                    ctx.move(to: CGPoint(x: x, y: y))
                }
                else
                {
                    ctx.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            ctx.strokePath()
        }
    }
    
    override func awakeFromNib() {
        let cellSize = calculateCellSize()
        
        func createLabelAt(_ rowIdx: Int, colIdx: Int, text: String?, cells: Int = 1) -> UILabel
        {
            let lbl = UILabel(frame: CGRect(x: CGFloat(colIdx)*cellSize.width, y: CGFloat(rowIdx)*cellSize.height, width: cellSize.width*CGFloat(cells), height: cellSize.height))
            lbl.backgroundColor = UIColor.clear
            lbl.text = text
            lbl.textColor = UIColor.white
            lbl.textAlignment = .center
            lbl.font = UIFont.systemFont(ofSize: isSmallScreen() ? 12 : 15, weight: UIFontWeightThin)
            lbl.adjustsFontSizeToFitWidth = true
            lbl.minimumScaleFactor = 0.5
            lbl.numberOfLines = 0
            lbl.tag = tag(rowIdx, colIdx)
            
            addSubview(lbl)
            return lbl
        }
        
        createLabelAt(0, colIdx: 2, text: lstr("Single player"))
        createLabelAt(0, colIdx: 3, text: lstr("Multiplayer"))
        createLabelAt(0, colIdx: 4, text: lstr("💎"))
        createLabelAt(4, colIdx: 1, text: lstr("Best score"))
        createLabelAt(5, colIdx: 1, text: lstr("Average score"))
        createLabelAt(6, colIdx: 1, text: lstr("Best score"))
        createLabelAt(7, colIdx: 1, text: lstr("Average score"))
        createLabelAt(1, colIdx: 0, text: lstr("Total played"), cells: 2)
        createLabelAt(2, colIdx: 0, text: lstr("Wins"), cells: 2)
        createLabelAt(3, colIdx: 0, text: lstr("Loses"), cells: 2)
        createLabelAt(4, colIdx: 0, text: "5")
        createLabelAt(5, colIdx: 0, text: "🎲")
        createLabelAt(6, colIdx: 0, text: "6")
        createLabelAt(7, colIdx: 0, text: "🎲")
        createLabelAt(8, colIdx: 0, text: "⭐️")
        createLabelAt(8, colIdx: 1, text: "-")
        createLabelAt(8, colIdx: 2, text: lstr("Stars desc"), cells: 3)
        
        for colIdx in 2...4
        {
            for rowIdx in 1...7
            {
                createLabelAt(rowIdx, colIdx: colIdx, text: "-")
            }
        }
        
        
        
    }
    
    func updateFrames()
    {
        let cellSize = calculateCellSize()
        
        for rowIdx in 0..<ctRows
        {
            for colIdx in 0..<ctColumns
            {
                if let subview = viewWithTag(rowIdx*ctColumns + colIdx), subview !== self
                {
                    var cells = 1
                    if colIdx == 0 && rowIdx <= 3
                    {
                        cells = 2
                    }
                    else if colIdx == 2 && rowIdx == 8
                    {
                        cells = 3
                    }
                    subview.frame = CGRect(x: CGFloat(colIdx)*cellSize.width, y: CGFloat(rowIdx)*cellSize.height, width: cellSize.width*CGFloat(cells), height: cellSize.height)
                }
            }
        }
    }
    
    func tag(_ rowIdx: Int, _ colIdx: Int) -> Int
    {
        return rowIdx*ctColumns + colIdx
    }
    
    func refreshStat()
    {
        let spLbl = viewWithTag(1*ctColumns + 2) as! UILabel
        let mpLbl = viewWithTag(1*ctColumns + 3) as! UILabel
        let winSpLbl = viewWithTag(2*ctColumns + 2) as! UILabel
        let winMpLbl = viewWithTag(2*ctColumns + 3) as! UILabel
        let loseSpLbl = viewWithTag(3*ctColumns + 2) as! UILabel
        let loseMpLbl = viewWithTag(3*ctColumns + 3) as! UILabel
        let totalDLbl = viewWithTag(1*ctColumns + 4) as! UILabel
        let winDLbl = viewWithTag(2*ctColumns + 4) as! UILabel
        let loseDLbl = viewWithTag(3*ctColumns + 4) as! UILabel
        let best5spLbl = viewWithTag(4*ctColumns + 2) as! UILabel
        let best6spLbl = viewWithTag(6*ctColumns + 2) as! UILabel
        let avg5spLbl = viewWithTag(5*ctColumns + 2) as! UILabel
        let avg6spLbl = viewWithTag(7*ctColumns + 2) as! UILabel
        let best5mpLbl = viewWithTag(4*ctColumns + 3) as! UILabel
        let best6mpLbl = viewWithTag(6*ctColumns + 3) as! UILabel
        let avg5mpLbl = viewWithTag(5*ctColumns + 3) as! UILabel
        let avg6mpLbl = viewWithTag(7*ctColumns + 3) as! UILabel
        let best5dLbl = viewWithTag(4*ctColumns + 4) as! UILabel
        let best6dLbl = viewWithTag(6*ctColumns + 4) as! UILabel
        let starsLbl = viewWithTag(8*ctColumns + 1) as! UILabel
        
        if let stat = playerStat
        {
            var playedSP = 0
            var playedMP = 0
            var winSP = 0, loseSP = 0
            var winMP = 0, loseMP = 0
            var winD = 0, loseD = 0
            var best5sp:UInt = 0, best5mp:UInt = 0, best6sp:UInt = 0, best6mp:UInt = 0
            var sum5sp:UInt = 0, sum6sp:UInt = 0, sum5mp:UInt = 0, sum6mp:UInt = 0
            var ct5sp:UInt = 0, ct6sp:UInt = 0, ct5mp:UInt = 0, ct6mp:UInt = 0
            var best5d = 0, best6d = 0
            
            for item in stat.items
            {
                if item.matchType == .SinglePlayer
                {
                    playedSP += 1
                    if item.result == .winner
                    {
                        winSP += 1
                    }
                    else if item.result == .loser
                    {
                        loseSP += 1
                    }
                
                    if item.diceNum == .five
                    {
                        best5sp = max(best5sp, item.score)
                        sum5sp += item.score
                        ct5sp += 1
                    }
                    else
                    {
                        best6sp = max(best6sp, item.score)
                        sum6sp += item.score
                        ct6sp += 1
                    }
                    
                }
                else
                {
                    playedMP += 1
                    if item.result == .winner
                    {
                        winMP += 1
                        winD += item.bet
                    }
                    else if item.result == .loser
                    {
                        loseMP += 1
                        loseD += item.bet
                    }
                    
                    if item.diceNum == .five
                    {
                        best5mp = max(best5mp, item.score)
                        sum5mp += item.score
                        ct5mp += 1
                    }
                    else
                    {
                        best6mp = max(best6mp, item.score)
                        sum6mp += item.score
                        ct6mp += 1
                    }
                    
                    if item.result == .winner
                    {
                        if item.diceNum == .five
                        {
                            best5d = max(best5d, item.bet)
                        }
                        else
                        {
                            best6d = max(best6d, item.bet)
                        }
                    }
                }
                
                
            }
            
            spLbl.text = String(playedSP)
            mpLbl.text = String(playedMP)
            winSpLbl.text = String(winSP)
            winMpLbl.text = String(winMP)
            loseSpLbl.text = String(loseSP)
            loseMpLbl.text = String(loseMP)
            winDLbl.text = String(winD)
            loseDLbl.text = String(loseD)
            totalDLbl.text = String(winD-loseD)
            best5spLbl.text = String(best5sp)
            best6spLbl.text = String(best6sp)
            avg5spLbl.text = ct5sp != 0 ? String(sum5sp/ct5sp) : "-"
            avg6spLbl.text = ct6sp != 0 ? String(sum6sp/ct6sp) : "-"
            best5mpLbl.text = String(best5mp)
            best6mpLbl.text = String(best6mp)
            avg5mpLbl.text = ct5mp != 0 ? String(sum5mp/ct5mp) : "-"
            avg6mpLbl.text = ct6mp != 0 ? String(sum6mp/ct6mp) : "-"
            best5dLbl.text = String(best5d)
            best6dLbl.text = String(best6d)
            starsLbl.text = starsFormatter.string(from: NSNumber(value: stars6(PlayerStat.avgScore(.six)) as Float))
        }
    }

}
