//
//  GameTableView.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

private let ctRows = 16
private let valueRows:[TableRow] = [.one, .two, .three, .four, .five, .six, .max, .min, .skala, .full, .poker, .yamb]

class GameTableView: UIView
{
    fileprivate func calculateCellSize() -> CGSize
    {
        let ctColumns = Match.shared.ctColumns
        let colWidth = round(frame.width/CGFloat(ctColumns)-0.5)
        let rowHeight = round(frame.height/16-0.5)
        return CGSize(width: colWidth, height: rowHeight)
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        let skin = (Match.shared.indexOfPlayerOnTurn == 0) ? Skin.blue : Skin.red
        
        // Drawing code
        
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        let cellSize = calculateCellSize()
        let ctColumns = Match.shared.ctColumns
        
        // width and height aligned to pixel
        let width = cellSize.width*CGFloat(ctColumns)
        let height = cellSize.height*CGFloat(ctRows)
        
        // stroke lines
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        
        ctx.beginPath()
        ctx.move(to: CGPoint(x: 0, y: 0))
        ctx.addLine(to: CGPoint(x: width, y: 0))
        ctx.addLine(to: CGPoint(x: width, y: height))
        ctx.addLine(to: CGPoint(x: 0, y: height))
        ctx.closePath()
        
        ctx.strokePath()
        
        
        for colIdx in 1..<ctColumns
        {
            let x = CGFloat(colIdx)*cellSize.width
            ctx.beginPath()
            ctx.move(to: CGPoint(x: x, y: 0))
            ctx.addLine(to: CGPoint(x: x, y: height))
            ctx.strokePath()
        }
        
        let fullLines = [1,7,8,10,11,15]
        for rowIdx in 1..<16
        {
            let y = CGFloat(rowIdx)*cellSize.height
            ctx.beginPath()
            ctx.move(to: CGPoint(x: 0, y: y))
            if fullLines.contains(rowIdx)
            {
                ctx.addLine(to: CGPoint(x: width, y: y))
            }
            else
            {
                ctx.addLine(to: CGPoint(x: width-cellSize.width, y: y))
            }
            ctx.strokePath()
        }
        
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        
        if let pos = player.inputPos
        {
            ctx.setStrokeColor(skin.strokeColor.cgColor)
            ctx.setLineWidth(1.25)
            
            ctx.beginPath()
            let x = CGFloat(pos.colIdx)*cellSize.width
            let y = CGFloat(pos.rowIdx)*cellSize.height
            ctx.move(to: CGPoint(x: x, y: y))
            ctx.addLine(to: CGPoint(x: x+cellSize.width, y: y))
            ctx.addLine(to: CGPoint(x: x+cellSize.width, y: y+cellSize.height))
            ctx.addLine(to: CGPoint(x: x, y: y+cellSize.height))
            ctx.closePath()
            ctx.strokePath()
            ctx.setLineWidth(1)
        }
        
    }
    
    func updateFrames()
    {
        let ctColumns = Match.shared.ctColumns
        let cellSize = calculateCellSize()
        
        for rowIdx in 0..<ctRows
        {
            for colIdx in 0..<ctColumns
            {
                for subview in subviews
                {
                    if subview.tag == (rowIdx*ctColumns + colIdx)
                    {
                        subview.frame = CGRect(x: CGFloat(colIdx)*cellSize.width, y: CGFloat(rowIdx)*cellSize.height, width: cellSize.width, height: cellSize.height)
                    }
                }
            }
        }
    }
    
    override func awakeFromNib()
    {
        let ctColumns = Match.shared.ctColumns
        let cellSize = calculateCellSize()
        
        func createLabel(at rowIdx: Int, colIdx: Int, text: String?) -> UILabel
        {
            let lbl = UILabel(frame: CGRect(x: CGFloat(colIdx)*cellSize.width, y: CGFloat(rowIdx)*cellSize.height, width: cellSize.width, height: cellSize.height))
            lbl.backgroundColor = Skin.blue.labelBackColor
            lbl.text = text
            lbl.textColor = UIColor.white
            lbl.textAlignment = .center
            lbl.tag = tag(rowIdx, colIdx)
            lbl.font = UIFont.systemFont(ofSize: isSmallScreen() ? 15 : 20)
            lbl.adjustsFontSizeToFitWidth = true
            lbl.minimumScaleFactor = 0.5
            
            addSubview(lbl)
            return lbl
        }
        
        func createBtn(atRowIdx rowIdx: Int, colIdx: Int, text: String?) -> UIButton
        {
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: CGFloat(colIdx)*cellSize.width, y: CGFloat(rowIdx)*cellSize.height, width: cellSize.width, height: cellSize.height)
            
            btn.setTitle(text, for: UIControlState())
            btn.setTitleColor(Skin.blue.tintColor, for: UIControlState())
            btn.setTitleColor(Skin.blue.tintColor, for: .disabled)
            btn.tag = rowIdx*ctColumns + colIdx
            btn.titleLabel?.font = UIFont(name: "Noteworthy", size: isSmallScreen() ? 15:18)
            btn.addTarget(self, action: #selector(onBtnPressed(_:)), for: .touchUpInside)
            btn.setBackgroundImage(UIImage.fromColor(Skin.blue.lightGrayColor), for: UIControlState())
            btn.setBackgroundImage(UIImage.fromColor(UIColor.white.withAlphaComponent(0)), for: .disabled)
            addSubview(btn)
            return btn
        }
        
        // bet
        if Match.shared.matchType == .OnlineMultiplayer && Match.shared.bet > 0
        {
            let betLbl = createLabel(at: 0, colIdx: 0, text: "\(Match.shared.bet) 💎")
            betLbl.font = UIFont.systemFont(ofSize: 10)
            betLbl.backgroundColor = UIColor.clear
            betLbl.textColor = UIColor.darkText
        }
        
        // header
        for colIdx in 1..<ctColumns
        {
            let _ = createLabel(at: 0, colIdx: colIdx, text: TableCol(rawValue: colIdx)!.name())
        }
        
        // first column titles
        for rowIdx in 1..<ctRows {
            let _ = createLabel(at: rowIdx, colIdx: 0, text: TableRow(rawValue: rowIdx)!.name())
        }
        
        // all buttons
        for row in valueRows
        {
            for colIdx in 1..<ctColumns-1
            {
                let _ = createBtn(atRowIdx: row.rawValue, colIdx: colIdx, text: "")
            }
        }
        
        let sumRows:[TableRow] = [.sumNumbers, .sumMaxMin, .sumSFPY]
        for row in sumRows
        {
            for colIdx in 1..<ctColumns
            {
                let sumLbl = createLabel(at: row.rawValue, colIdx: colIdx, text: "")
                sumLbl.font = UIFont(name: "Noteworthy-Bold", size: isSmallScreen() ? 15 : 18)
                sumLbl.textColor = Skin.blue.tintColor
            }
        }
        
        updateValuesAndStates()
    }
    
    func updateValuesAndStates()
    {
        let skin = (Match.shared.indexOfPlayerOnTurn == 0) ? Skin.blue : Skin.red
        
        let player = Match.shared.players[Match.shared.indexOfPlayerOnTurn]
        let tableValues = player.table.values
        let inputPos = player.inputPos
        let inputState = player.inputState
        let gameState = player.state
        
        // zero column, update color only
        for rowIdx in 1..<16
        {
            guard let lbl = viewWithTag(tag(rowIdx, 0)) as? UILabel else {continue}
            lbl.backgroundColor = skin.labelBackColor
        }
        
        // set values
        for colIdx in 1..<Match.shared.ctColumns
        {
            // zero row
            guard let lbl = viewWithTag(tag(0, colIdx)) as? UILabel else {continue}
            lbl.backgroundColor = skin.labelBackColor
            
            // value rows
            for row in valueRows
            {
                guard let btn = viewWithTag(tag(row.rawValue, colIdx)) as? UIButton else {continue}
                
                btn.setTitleColor(skin.tintColor, for: UIControlState())
                btn.setTitleColor(skin.tintColor, for: .disabled)
                
                let value = tableValues[colIdx][row.rawValue]
                let pos = TablePos(rowIdx: row.rawValue, colIdx: colIdx)
                
                if value != nil
                {
                    if colIdx == TableCol.n.rawValue && inputPos == pos && gameState != .afterN3 && gameState != .endGame
                    {
                        btn.setTitle(String(value!) + " ?", for: UIControlState())
                    }
                    else
                    {
                        btn.setTitle(String(value!), for: UIControlState())
                    }
                }
                else
                {
                    btn.setTitle(nil, for: UIControlState())
                }
                
            }
        }
        
        // down col
        let downColIdx = TableCol.down.rawValue
        for (idx,row) in valueRows.enumerated() {
            guard let btn = viewWithTag(tag(row.rawValue, downColIdx)) as? UIButton else {continue}
            
            let value = tableValues[downColIdx][row.rawValue]
            
            // in most cases button is disabled, find only cases when it should be enabled
            btn.isEnabled = false
            if inputState != .notAllowed
            {
                if row == .one
                {
                    btn.isEnabled = (value == nil) || inputPos == TablePos(rowIdx: 1, colIdx: downColIdx)
                }
                else
                {
                    if value == nil
                    {
                        let prevRow = valueRows[idx-1]
                        let prevValue = tableValues[downColIdx][prevRow.rawValue]
                        if  prevValue != nil
                        {
                            if let inputPos = inputPos, inputPos == TablePos(rowIdx: prevRow.rawValue,colIdx: downColIdx)
                            {
                                btn.isEnabled = false
                            }
                            else
                            {
                                btn.isEnabled = true
                            }
                        }
                    }
                    else
                    {
                        btn.isEnabled = inputPos == TablePos(rowIdx: row.rawValue, colIdx: downColIdx)
                    }
                }
            }
        }
        
        // up col
        let upColIdx = TableCol.up.rawValue
        for (idx,row) in valueRows.enumerated() {
            guard let btn = viewWithTag(tag(row.rawValue, upColIdx)) as? UIButton else {continue}
            
            let value = tableValues[upColIdx][row.rawValue]
            
            // in most cases button is disabled, find only cases when it should be enabled
            btn.isEnabled = false
            if inputState != .notAllowed
            {
                if row == .yamb
                {
                    btn.isEnabled = (value == nil) || inputPos == TablePos(rowIdx: TableRow.yamb.rawValue, colIdx: upColIdx)
                }
                else
                {
                    if value == nil
                    {
                        let nextRow = valueRows[idx+1]
                        let nextValue = tableValues[upColIdx][nextRow.rawValue]
                        if nextValue != nil
                        {
                            if let inputPos = inputPos, inputPos == TablePos(rowIdx: nextRow.rawValue,colIdx: upColIdx)
                            {
                                btn.isEnabled = false
                            }
                            else
                            {
                                btn.isEnabled = true
                            }
                        }
                    }
                    else
                    {
                        btn.isEnabled = inputPos == TablePos(rowIdx: row.rawValue, colIdx: upColIdx)
                    }
                }
            }
        }
        
    
        // up down col
        let upDownColIdx = TableCol.upDown.rawValue
        for (_,row) in valueRows.enumerated()
        {
            guard let btn = viewWithTag(tag(row.rawValue, upDownColIdx)) as? UIButton else {continue}
            btn.isEnabled = false
            if inputState != .notAllowed
            {
                let value = tableValues[upDownColIdx][row.rawValue]
                let pos = TablePos(rowIdx: row.rawValue, colIdx: upDownColIdx)
                btn.isEnabled = value == nil || inputPos == pos
            }
        }
        
        // N column
        let nColIdx = TableCol.n.rawValue
        for (_,row) in valueRows.enumerated()
        {
            guard let btn = viewWithTag(tag(row.rawValue, nColIdx)) as? UIButton else {continue}
            btn.isEnabled = false
            let pos = TablePos(rowIdx: row.rawValue, colIdx: nColIdx)
            if inputState != .notAllowed && player.state == .after1
            {
                let value = tableValues[nColIdx][row.rawValue]
                btn.isEnabled = value == nil || inputPos == pos
            }
            else if inputState == .notAllowed && player.state == .afterN2
            {
                btn.isEnabled = (inputPos == pos)
            }
        }
        
        // sum labels
        for colIdx in 1..<Match.shared.ctColumns
        {
            for rowIdx in [
                TableRow.sumNumbers.rawValue,
                TableRow.sumMaxMin.rawValue,
                TableRow.sumSFPY.rawValue]
            {
                guard let lbl = viewWithTag(tag(rowIdx, colIdx)) as? UILabel else {continue}
                if let value = tableValues[colIdx][rowIdx]
                {
                    lbl.text = String(value)
                }
                else
                {
                    lbl.text = nil
                }
                lbl.backgroundColor = skin.labelBackColor
                lbl.textColor = skin.tintColor
            }
        }
    
    }

    @objc
    func onBtnPressed(_ sender: UIButton)
    {
        if Match.shared.matchType == .OnlineMultiplayer && !Match.shared.isLocalPlayerTurn()
        {
            return
        }
        
        let ctColumns = Match.shared.ctColumns
        let rowIdx = sender.tag/ctColumns
        let colIdx = sender.tag-rowIdx*ctColumns
        let pos = TablePos(rowIdx: rowIdx, colIdx: colIdx)
        print(rowIdx,colIdx)
        
        Match.shared.didSelectCellAtPos(pos)
    }
    
    func tag(_ rowIdx: Int, _ colIdx: Int) -> Int
    {
        return rowIdx*Match.shared.ctColumns + colIdx
    }

}
