//
//  GameTableView.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

let ctRows = 16
let valueRows:[TableRow] = [.One, .Two, .Three, .Four, .Five, .Six, .Max, .Min, .Skala, .Full, .Poker, .Yamb]

class GameTableView: UIView
{
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        let skin = (Game.shared.idxPlayer == 0) ? Skin.blue : Skin.red
        
        // Drawing code
        
        let ctColumns = Game.shared.ctColumns
        let colWidth = round(CGRectGetWidth(rect)/CGFloat(ctColumns)-0.5)
        let rowHeight = round(CGRectGetHeight(rect)/16-0.5)
        guard let ctx = UIGraphicsGetCurrentContext() else {return}
        
        // width and height aligned to pixel
        let width = colWidth*CGFloat(ctColumns)
        let height = rowHeight*CGFloat(ctRows)
        
        // stroke lines
        CGContextSetStrokeColorWithColor(ctx, UIColor.lightGrayColor().CGColor)
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, 0, 0)
        CGContextAddLineToPoint(ctx, width, 0)
        CGContextAddLineToPoint(ctx, width, height)
        CGContextAddLineToPoint(ctx, 0, height)
        CGContextClosePath(ctx)
        
        CGContextStrokePath(ctx)
        
        
        for colIdx in 1..<ctColumns
        {
            let x = CGFloat(colIdx)*colWidth
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, x, 0)
            CGContextAddLineToPoint(ctx, x, height)
            CGContextStrokePath(ctx)
        }
        
        let fullLines = [1,7,8,10,11,15]
        for rowIdx in 1..<16
        {
            let y = CGFloat(rowIdx)*rowHeight
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 0, y)
            if fullLines.contains(rowIdx)
            {
                CGContextAddLineToPoint(ctx, width, y)
            }
            else
            {
                CGContextAddLineToPoint(ctx, width-colWidth, y)
            }
            CGContextStrokePath(ctx)
        }
        
        let player = Game.shared.players[Game.shared.idxPlayer]
        
        if let pos = player.inputPos
        {
            CGContextSetStrokeColorWithColor(ctx, skin.strokeColor.CGColor)
            
            CGContextBeginPath(ctx)
            let x = CGFloat(pos.colIdx)*colWidth
            let y = CGFloat(pos.rowIdx)*rowHeight
            CGContextMoveToPoint(ctx, x, y)
            CGContextAddLineToPoint(ctx, x+colWidth, y)
            CGContextAddLineToPoint(ctx, x+colWidth, y+rowHeight)
            CGContextAddLineToPoint(ctx, x, y+rowHeight)
            CGContextClosePath(ctx)
            CGContextStrokePath(ctx)
        }
        
    }
    
    func updateFrames()
    {
        let ctColumns = Game.shared.ctColumns
        
        let colWidth = round(CGRectGetWidth(frame)/CGFloat(ctColumns)-0.5)
        let rowHeight = round(CGRectGetHeight(frame)/CGFloat(ctRows)-0.5)
        
        for rowIdx in 0..<ctRows
        {
            for colIdx in 0..<ctColumns
            {
                if let subview = viewWithTag(rowIdx*ctColumns + colIdx) where subview !== self
                {
                    subview.frame = CGRect(x: CGFloat(colIdx)*colWidth, y: CGFloat(rowIdx)*rowHeight, width: colWidth, height: rowHeight)
                }
            }
        }
    }
    
    override func awakeFromNib()
    {
        let ctColumns = Game.shared.ctColumns
        let colWidth = round(CGRectGetWidth(self.frame)/CGFloat(ctColumns)-0.5)
        let rowHeight = round(CGRectGetHeight(self.frame)/16-0.5)
        
        func createLabelAt(rowIdx: Int, colIdx: Int, text: String?) -> UILabel
        {
            let lbl = UILabel(frame: CGRect(x: CGFloat(colIdx)*colWidth, y: CGFloat(rowIdx)*rowHeight, width: colWidth, height: rowHeight))
            lbl.backgroundColor = Skin.blue.labelBackColor
            lbl.text = text
            lbl.textColor = UIColor.whiteColor()
            lbl.textAlignment = .Center
            lbl.tag = tag(rowIdx, colIdx)
            lbl.font = UIFont.systemFontOfSize(isSmallScreen() ? 15 : 20)
            lbl.adjustsFontSizeToFitWidth = true
            lbl.minimumScaleFactor = 0.5
            
            addSubview(lbl)
            return lbl
        }
        
        func createBtnAt(rowIdx: Int, colIdx: Int, text: String?) -> UIButton
        {
            let btn = UIButton(type: .Custom)
            btn.frame = CGRect(x: CGFloat(colIdx)*colWidth, y: CGFloat(rowIdx)*rowHeight, width: colWidth, height: rowHeight)
            
            btn.setTitle(text, forState: .Normal)
            btn.setTitleColor(Skin.blue.tintColor, forState: .Normal)
            btn.setTitleColor(Skin.blue.tintColor, forState: .Disabled)
            btn.tag = rowIdx*ctColumns + colIdx
            btn.titleLabel?.font = UIFont(name: "Noteworthy", size: isSmallScreen() ? 15:18)
            btn.addTarget(self, action: #selector(onBtnPressed(_:)), forControlEvents: .TouchUpInside)
            btn.setBackgroundImage(UIImage.fromColor(Skin.blue.lightGrayColor), forState: .Normal)
            btn.setBackgroundImage(UIImage.fromColor(UIColor.whiteColor().colorWithAlphaComponent(0)), forState: .Disabled)
            addSubview(btn)
            return btn
        }
        
        // header
        for colIdx in 1..<ctColumns
        {
            createLabelAt(0, colIdx: colIdx, text: TableCol(rawValue: colIdx)!.name())
        }
        
        // first column titles
        for rowIdx in 1..<ctRows {
            createLabelAt(rowIdx, colIdx: 0, text: TableRow(rawValue: rowIdx)!.name())
        }
        
        // all buttons
        for row in valueRows
        {
            for colIdx in 1..<ctColumns-1
            {
                createBtnAt(row.rawValue, colIdx: colIdx, text: "")
            }
        }
        
        let sumRows:[TableRow] = [.SumNumbers, .SumMaxMin, .SumSFPY]
        for row in sumRows
        {
            for colIdx in 1..<ctColumns
            {
                let sumLbl = createLabelAt(row.rawValue, colIdx: colIdx, text: "")
                sumLbl.font = UIFont(name: "Noteworthy-Bold", size: isSmallScreen() ? 15 : 18)
                sumLbl.textColor = Skin.blue.tintColor
            }
        }
        
        updateValuesAndStates()
    }
    
    func updateValuesAndStates()
    {
        let skin = (Game.shared.idxPlayer == 0) ? Skin.blue : Skin.red
        
        let player = Game.shared.players[Game.shared.idxPlayer]
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
        for colIdx in 1..<Game.shared.ctColumns
        {
            // zero row
            guard let lbl = viewWithTag(tag(0, colIdx)) as? UILabel else {continue}
            lbl.backgroundColor = skin.labelBackColor
            
            // value rows
            for row in valueRows
            {
                guard let btn = viewWithTag(tag(row.rawValue, colIdx)) as? UIButton else {continue}
                
                let value = tableValues[colIdx][row.rawValue]
                let pos = TablePos(rowIdx: row.rawValue, colIdx: colIdx)
                
                if value != nil
                {
                    if colIdx == TableCol.N.rawValue && inputPos == pos && gameState != .AfterN3 && gameState != .End
                    {
                        btn.setTitle(String(value!) + " ?", forState: .Normal)
                    }
                    else
                    {
                        btn.setTitle(String(value!), forState: .Normal)
                    }
                }
                else
                {
                    btn.setTitle(nil, forState: .Normal)
                }
                
            }
        }
        
        // down col
        let downColIdx = TableCol.Down.rawValue
        for (idx,row) in valueRows.enumerate() {
            guard let btn = viewWithTag(tag(row.rawValue, downColIdx)) as? UIButton else {continue}
            
            let value = tableValues[downColIdx][row.rawValue]
            
            // in most cases button is disabled, find only cases when it should be enabled
            btn.enabled = false
            if inputState != .NotAllowed
            {
                if row == .One
                {
                    btn.enabled = (value == nil) || inputPos == TablePos(rowIdx: 1, colIdx: downColIdx)
                }
                else
                {
                    if value == nil
                    {
                        let prevRow = valueRows[idx-1]
                        let prevValue = tableValues[downColIdx][prevRow.rawValue]
                        if  prevValue != nil
                        {
                            if let inputPos = inputPos where inputPos == TablePos(rowIdx: prevRow.rawValue,colIdx: downColIdx)
                            {
                                btn.enabled = false
                            }
                            else
                            {
                                btn.enabled = true
                            }
                        }
                    }
                    else
                    {
                        btn.enabled = inputPos == TablePos(rowIdx: row.rawValue, colIdx: downColIdx)
                    }
                }
            }
        }
        
        // up col
        let upColIdx = TableCol.Up.rawValue
        for (idx,row) in valueRows.enumerate() {
            guard let btn = viewWithTag(tag(row.rawValue, upColIdx)) as? UIButton else {continue}
            
            let value = tableValues[upColIdx][row.rawValue]
            
            // in most cases button is disabled, find only cases when it should be enabled
            btn.enabled = false
            if inputState != .NotAllowed
            {
                if row == .Yamb
                {
                    btn.enabled = (value == nil) || inputPos == TablePos(rowIdx: TableRow.Yamb.rawValue, colIdx: upColIdx)
                }
                else
                {
                    if value == nil
                    {
                        let nextRow = valueRows[idx+1]
                        let nextValue = tableValues[upColIdx][nextRow.rawValue]
                        if nextValue != nil
                        {
                            if let inputPos = inputPos where inputPos == TablePos(rowIdx: nextRow.rawValue,colIdx: upColIdx)
                            {
                                btn.enabled = false
                            }
                            else
                            {
                                btn.enabled = true
                            }
                        }
                    }
                    else
                    {
                        btn.enabled = inputPos == TablePos(rowIdx: row.rawValue, colIdx: upColIdx)
                    }
                }
            }
        }
        
    
        // up down col
        let upDownColIdx = TableCol.UpDown.rawValue
        for (_,row) in valueRows.enumerate()
        {
            guard let btn = viewWithTag(tag(row.rawValue, upDownColIdx)) as? UIButton else {continue}
            btn.enabled = false
            if inputState != .NotAllowed
            {
                let value = tableValues[upDownColIdx][row.rawValue]
                let pos = TablePos(rowIdx: row.rawValue, colIdx: upDownColIdx)
                btn.enabled = value == nil || inputPos == pos
            }
        }
        
        // N column
        let nColIdx = TableCol.N.rawValue
        for (_,row) in valueRows.enumerate()
        {
            guard let btn = viewWithTag(tag(row.rawValue, nColIdx)) as? UIButton else {continue}
            btn.enabled = false
            let pos = TablePos(rowIdx: row.rawValue, colIdx: nColIdx)
            if inputState != .NotAllowed && player.state == .After1
            {
                let value = tableValues[nColIdx][row.rawValue]
                btn.enabled = value == nil || inputPos == pos
            }
            else if inputState == .NotAllowed && player.state == .AfterN2
            {
                btn.enabled = (inputPos == pos)
            }
        }
        
        // sum labels
        for colIdx in 1..<Game.shared.ctColumns
        {
            for rowIdx in [
                TableRow.SumNumbers.rawValue,
                TableRow.SumMaxMin.rawValue,
                TableRow.SumSFPY.rawValue]
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
            }
        }
    
    }

    @objc
    func onBtnPressed(sender: UIButton)
    {
        
        let ctColumns = Game.shared.ctColumns
        let rowIdx = sender.tag/ctColumns
        let colIdx = sender.tag-rowIdx*ctColumns
        let pos = TablePos(rowIdx: rowIdx, colIdx: colIdx)
        print(rowIdx,colIdx)
        
        Game.shared.didSelectCellAtPos(pos)
    }
    
    func tag(rowIdx: Int, _ colIdx: Int) -> Int
    {
        return rowIdx*Game.shared.ctColumns + colIdx
    }

}
