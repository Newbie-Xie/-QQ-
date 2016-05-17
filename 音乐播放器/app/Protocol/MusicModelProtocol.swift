//
//  MusicModelProtocol.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/21.
//  Copyright © 2016年 2期. All rights reserved.
//

import Foundation

enum MusicType: Int {
    case local = 1, remote
}

protocol MusicModelProtocol
{
    /// 图片
    var imageName: String { get }
    /// 歌词
    var lyric: String { get }
    /// 本地歌曲路径
    var mp3: String { get }
    /// 歌曲名
    var name: String { get }
    /// 歌手名
    var singer: String { get }
    /// 专辑名
    var album: String { get }
    /// 歌曲类型
    var type: MusicType { get }
    
    static func modals() -> [MusicModelProtocol]
}