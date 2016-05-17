//
//  LyricParser.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/22.
//  Copyright © 2016年 2期. All rights reserved.
//

import Foundation


let dateFormatter = NSDateFormatter()


struct LyricParser
{
    static func LyricsFromFile<T: LyricProtocol>(fileName name: String) -> [T]
    {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: nil)
            else{ print("歌词文件路径不存在"); return [] }
        
        guard let lyrics = try? NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                                .componentsSeparatedByString("\n") as [NSString]
            else { print("获取歌词字符串失败"); return[] }
     
        /*
         [00:00.00]月半小夜曲 李克勤
         [00:19.00]曲：河合奈保子 词：向雪怀
         
         [02:19.00][00:23.00]仍然倚在失眠夜望天边星宿
         [02:25.00][00:29.00]仍然听见小提琴如泣似诉再挑逗
         [02:31.00][00:35.00]为何只剩一弯月留在我的天空
         [02:38.00][00:42.00]这晚以后音讯隔绝
         */
        
        let pattern = "\\[\\d{2}:\\d{2}\\.\\d{2}\\]"
        
        guard let reg = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions(rawValue:0)) else { print("创建正则表达式失败"); return [] }
        
        dateFormatter.dateFormat = "[mm:ss.SS]"
        let beginDate = dateFormatter.dateFromString("[00:00.00]")!
        
        var models = [T]()
        /// 遍历从文件中取出的每句歌词数组
        for lrc in lyrics {
            do{
                /// 匹配出每句歌词
                let results = reg.matchesInString(lrc as String, options: NSMatchingOptions(rawValue:0), range: NSMakeRange(0, lrc.length))
                
                for cheking in results {
                    do{
                        /// 取出每句歌词的开始时间
                        let beginTimeStr = lrc.substringWithRange(cheking.range)
                        
                        if  let last = results.last {
                            /// 取出每句歌词
                            let content = lrc.substringFromIndex(last.range.location + last.range.length)
                            /// 计算每句歌词的开始时间
                            let beginTime = dateFormatter.dateFromString(beginTimeStr)?.timeIntervalSinceDate(beginDate) ?? 0.0
                            models.append(T(time: beginTime, content: content))
                        }
                    }
                }
            }
        }
        models.sortInPlace{ $0.0.beginTime < $0.1.beginTime }
        return models
    }
}
