//
//  MusicModel.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/21.
//  Copyright © 2016年 2期. All rights reserved.
//

import Foundation

struct MusicModal: MusicModelProtocol
{
    
    let imageName: String
    let lyric: String
    let mp3: String
    let name: String
    let singer: String
    let album: String
    let type: MusicType
    
    static func modals() -> [MusicModelProtocol]
    {
        let path = NSBundle.mainBundle().pathForResource("mlist.plist", ofType: nil)!
        let arr = NSArray(contentsOfFile: path)
        
        var models = [MusicModelProtocol]()
        for dic in arr!
        {
            let image = dic["image"] as! String
            let lyric = dic["lrc"] as! String
            let mp3 = dic["mp3"] as! String
            let name = dic["name"] as! String
            let singer = dic["singer"] as! String
            let album = dic["album"] as! String
            let type = dic["type"] as! Int
            
            let mscType: MusicType = (type == 2) ? .remote : .local
            
             models.append(MusicModal(imageName: image, lyric: lyric, mp3: mp3, name: name, singer: singer, album: album, type: mscType))
            
        }
        
        return models
    }

}