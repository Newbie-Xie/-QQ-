//
//  LyricLabel.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/24.
//  Copyright © 2016年 2期. All rights reserved.
//

import UIKit

class LyricLabel: UILabel
{
    var progess = 0.0 {
        didSet{
            setNeedsDisplay()
        }
    }

    override func drawRect(rect: CGRect)
    {
        super.drawRect(rect)
        
        let wid = rect.width * CGFloat(progess)
        UIColor.greenColor().set()
        UIRectFillUsingBlendMode(CGRectMake(rect.origin.x, rect.origin.y, wid, rect.height), .SourceIn)
    }
    
}
