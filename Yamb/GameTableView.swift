//
//  GameTableView.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

let ctRows = 16
let valueRows:[PlaySection] = [.One, .Two, .Three, .Four, .Five, .Six, .Max, .Min, .Skala, .Full, .Poker, .Yamb]

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
            lbl.backgroundColor = UIColor(netHex:0xCCC8D7FF)
            lbl.text = text
            lbl.textColor = UIColor.whiteColor()
            lbl.textAlignment = .Center
            lbl.tag = tag(rowIdx, colIdx)
            lbl.font = UIFont.systemFontOfSize(isSmallScreen() ? 15 : 20)
            lbl.layer.shadowColor = UIColor.grayColor().CGColor
            lbl.layer.shadowOffset = CGSizeMake(2, 2)
            addSubview(lbl)
            return lbl
        }
        
        func createBtnAt(rowIdx: Int, colIdx: Int, text: String?) -> UIButton
        {
            let btn = UIButton(type: .Custom)
            btn.frame = CGRect(x: CGFloat(colIdx)*colWidth, y: CGFloat(rowIdx)*rowHeight, width: colWidth, height: rowHeight)
            
            btn.setTitle(text, forState: .Normal)
            btn.setTitleColor(UIColor.blueColor(), forState: .Normal)
            btn.tag = rowIdx*ctColumns + colIdx
            btn.titleLabel?.font = UIFont(name: "Noteworthy", size: 15)
            btn.addTarget(self, action: #selector(onBtnPressed(_:)), forControlEvents: .TouchUpInside)
            btn.setBackgroundImage(UIImage.fromColor(UIColor.lightGrayColor()), forState: .Disabled)
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
            createLabelAt(rowIdx, colIdx: 0, text: PlaySection(rawValue: rowIdx)!.name())
        }
        
        // all buttons
        for row in valueRows
        {
            for colIdx in 1..<ctColumns
            {
                createBtnAt(row.rawValue, colIdx: colIdx, text: "")
            }
        }
        
        let sumRows:[PlaySection] = [.SumNumbers, .SumMaxMin, .SumSFPY]
        for row in sumRows
        {
            for colIdx in 1..<ctColumns
            {
                createLabelAt(row.rawValue, colIdx: colIdx, text: "")
            }
        }
    }
    
    func updateValuesAndStates()
    {
        
        // down col
        for row in valueRows {
            if let btn = viewWithTag(tag(row.rawValue, 1)) as? UIButton
            {
                if Game.shared.inputState == .NotAllowed
                {
                    btn.enabled = true
                }
                else
                {
                    btn.enabled = false
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
