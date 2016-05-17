//
//  LyricModel.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/22.
//  Copyright © 2016年 2期. All rights reserved.
//

import Foundation

struct LyricModel: LyricProtocol
{
    /// 歌词开始时间
    let beginTime: NSTimeInterval
    /// 歌词内容
    let content: String
    
    init(time: NSTimeInterval, content: String)
    {
        self.beginTime = time
        self.content = content
    }
}