//
//  GameTableView.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

let ctRows = 16
let valueRows:[TableSection] = [.One, .Two, .Three, .Four, .Five, .Six, .Max, .Min, .Skala, .Full, .Poker, .Yamb]

class GameTableView: UIView
{
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let ctx = UIGraphicsGetCurrentContext()
        
        // stroke lines
        CGContextSetStrokeColorWithColor(ctx, UIColor.lightGrayColor().CGColor)
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, 0, 0)
        CGContextAddLineToPoint(ctx, rect.size.width, 0)
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height)
        CGContextAddLineToPoint(ctx, 0, rect.size.height)
        CGContextClosePath(ctx)
        
        CGContextStrokePath(ctx)
        
        let ctColumns = Game.shared.ctColumns
        let colWidth = round(CGRectGetWidth(rect)/CGFloat(ctColumns))
        let rowHeight = round(CGRectGetHeight(rect)/16)
        for colIdx in 1..<ctColumns
        {
            let x = CGFloat(colIdx)*colWidth
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, x, 0)
            CGContextAddLineToPoint(ctx, x, rect.size.height)
            CGContextStrokePath(ctx)
        }
        
        for rowIdx in 1..<16
        {
            let y = CGFloat(rowIdx)*rowHeight
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, 0, y)
            CGContextAddLineToPoint(ctx, rect.size.width, y)
            CGContextStrokePath(ctx)
        }
        
    }
    
    func updateFrames()
    {
        let ctColumns = Game.shared.ctColumns
        
        let colWidth = round(CGRectGetWidth(frame)/CGFloat(ctColumns))
        let rowHeight = round(CGRectGetHeight(frame)/CGFloat(ctRows))
        
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
        let colWidth = round(CGRectGetWidth(self.frame)/CGFloat(ctColumns))
        let rowHeight = round(CGRectGetHeight(self.frame)/16)
        
        func createLabelAt(rowIdx: Int, colIdx: Int, text: String?) -> UILabel
        {
            let lbl = UILabel(frame: CGRect(x: CGFloat(colIdx)*colWidth, y: CGFloat(rowIdx)*rowHeight, width: colWidth, height: rowHeight))
            lbl.backgroundColor = Skin.labelBlueBackColor
            lbl.text = text
            lbl.textColor = UIColor.whiteColor()
            lbl.textAlignment = .Center
            lbl.tag = tag(rowIdx, colIdx)
            lbl.font = UIFont.systemFontOfSize(isSmallScreen() ? 15 : 20)
            
            addSubview(lbl)
            return lbl
        }
        
        func createBtnAt(rowIdx: Int, colIdx: Int, text: String?) -> UIButton
        {
            let btn = UIButton(type: .Custom)
            btn.frame = CGRect(x: CGFloat(colIdx)*colWidth, y: CGFloat(rowIdx)*rowHeight, width: colWidth, height: rowHeight)
            
            btn.setTitle(text, forState: .Normal)
            btn.setTitleColor(Skin.tintColor, forState: .Normal)
            btn.setTitleColor(Skin.tintColor, forState: .Disabled)
            btn.tag = rowIdx*ctColumns + colIdx
            btn.titleLabel?.font = UIFont(name: "Noteworthy", size: 15)
            btn.addTarget(self, action: #selector(onBtnPressed(_:)), forControlEvents: .TouchUpInside)
            btn.setBackgroundImage(UIImage.fromColor(Skin.lightGrayColor), forState: .Normal)
            btn.setBackgroundImage(UIImage.fromColor(UIColor.whiteColor().colorWithAlphaComponent(0)), forState: .Disabled)
            addSubview(btn)
            return btn
        }
        
        // header
        let titles = ["","↓","↑","⇅","N"]
        for colIdx in 1..<ctColumns
        {
            createLabelAt(0, colIdx: colIdx, text: titles[colIdx])
        }
        
        // first column titles
        for rowIdx in 1..<ctRows {
            createLabelAt(rowIdx, colIdx: 0, text: TableSection(rawValue: rowIdx)!.name())
        }
        
        // all buttons
        for row in valueRows
        {
            for colIdx in 1..<ctColumns
            {
                createBtnAt(row.rawValue, colIdx: colIdx, text: "")
            }
        }
        
        let sumRows:[TableSection] = [.SumNumbers, .SumMaxMin, .SumSFPY]
        for row in sumRows
        {
            for colIdx in 1..<ctColumns
            {
                createLabelAt(row.rawValue, colIdx: colIdx, text: "")
            }
        }
        
        updateValuesAndStates()
    }
    
    func updateValuesAndStates()
    {
        let tableValues = Game.shared.tableValues
        
        // set values
        for colIdx in 1..<Game.shared.ctColumns
        {
            for row in valueRows
            {
                guard let btn = viewWithTag(tag(row.rawValue, colIdx)) as? UIButton else {continue}
                
                let value = tableValues[colIdx][row.rawValue]
                
                if value != nil
                {
                    btn.setTitle(String(value!), forState: .Normal)
                }
                else
                {
                    btn.setTitle(nil, forState: .Normal)
                }
                
            }
        }
        
        // down col
        for (idx,row) in valueRows.enumerate() {
            guard let btn = viewWithTag(tag(row.rawValue, 1)) as? UIButton else {continue}
            
            let value = tableValues[1][row.rawValue]
            
            // in most cases button is disabled, find only cases when it should be enabled
            btn.enabled = false
            if Game.shared.inputState != .NotAllowed
            {
                if idx == 0
                {
                    btn.enabled = value == nil
                }
                else
                {
                    if tableValues[1][row.rawValue] == nil
                    {
                        let prevRow = valueRows[idx-1]
                        if tableValues[1][prevRow.rawValue] != nil
                        {
                            if let lastInputPos = Game.shared.inputPos where lastInputPos == TablePos(rowIdx: prevRow.rawValue,colIdx: 1) && Game.shared.inputState == .Allowed
                            {
                                btn.enabled = false
                            }
                            else
                            {
                                btn.enabled = true
                            }
                        }
                    }
                }
            }
        }
        
    
        // up down col
        for (_,row) in valueRows.enumerate()
        {
            guard let btn = viewWithTag(tag(row.rawValue, 3)) as? UIButton else {continue}
            btn.enabled = false
            if Game.shared.inputState != .NotAllowed
            {
                let value = tableValues[3][row.rawValue]
                let pos = TablePos(rowIdx: row.rawValue, colIdx: 3)
                btn.enabled = value == nil || Game.shared.inputPos == pos
            }
        }
        
        // sum labels
        for colIdx in 1..<Game.shared.ctColumns
        {
            for rowIdx in [
                TableSection.SumNumbers.rawValue,
                TableSection.SumMaxMin.rawValue,
                TableSection.SumSFPY.rawValue]
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
