//
//  LyricProtocol.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/22.
//  Copyright © 2016年 2期. All rights reserved.
//

import Foundation

protocol LyricProtocol
{
    /// 歌词开始时间
    var beginTime: NSTimeInterval { get }
    /// 歌词内容
    var content: String { get }
    
    init(time: NSTimeInterval, content: String)
}