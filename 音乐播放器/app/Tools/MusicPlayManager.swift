//
//  MusicPlayManager.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/22.
//  Copyright © 2016年 2期. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayManagerDelegate: class {
    /// 更新播放进度
    func updateProgess(progess: Double)
    /// 播放结束
    func playerDidFinishPlaying(successfully flag: Bool)
    /**
     播放当前的歌词
     
     - parameter lyric:    歌词模型
     - parameter nextTime: 下一句歌词的开始的时间.如果小于0,则代表当前是最后一句歌词
     */
    func updateLyric(lyric: LyricProtocol, atIndex: Int, nextTime: Double)
}


extension PlayManagerDelegate {
    func updateProgess(progess: Double){}
    func playerDidFinishPlaying(successfully flag: Bool){}
    func updateLyric(lyric: LyricProtocol, atIndex: Int, nextTime: Double){}
}


final class PlayManager: NSObject
{
    /// 单例
    static let manager = PlayManager()
    /// 代理
    weak var delegate: PlayManagerDelegate?
    /// 歌词模型数组
    private(set) var lyrics = [LyricModel]()
    
    /// 歌曲的持续时间
    var duration: NSTimeInterval {
       return self.player?.duration ?? 0.0
    }
    
    /// 当前歌曲播放的时间
    var currentTime: NSTimeInterval {
        get {
            guard let p = self.player else { return 0.0 }
            return p.currentTime
        }
        set {
            self.player?.currentTime = min(max(0, newValue), self.duration)
            
            /// 每次准备播放时,假设当前歌曲与下一句歌词的差值为0
            /// 以便重新计算当前歌词的位置
            flag = 0.0
        }
    }
    
//MARK: - ---------------- public method ----------------
    
    /// 准备播放音乐
    func preparePlay(music: MusicModelProtocol)
    {
        /// 每次准备播放时,假设当前歌曲与下一句歌词的差值为0
        /// 以便重新计算当前歌词的位置
        flag = 0
        /// 清空player
        player?.delegate = nil; player = nil
        do {
            guard let url = NSBundle.mainBundle().URLForResource(music.mp3, withExtension: nil)
                else{
                    print("音乐路径不存在"); return
            }
            player = try AVAudioPlayer(contentsOfURL: url)
            player?.prepareToPlay()
            player?.delegate = self
            
            lyrics.removeAll()
            lyrics = LyricParser.LyricsFromFile(fileName: music.lyric)
            
        }catch{
            print("创建音乐播放器失败: \(error)")
        }
    }
    
    /// 播放音乐
    func play() {
        /// 设置播放类型
        let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        player?.play()
        startUpProgess()
    }
    
    /// 暂停音乐
    func pause() { player?.pause(); stopUpProgess() }
    
//MARK: - ---------------- private method ----------------
    /// 开始更新进度条
    private func startUpProgess()
    {
        stopUpProgess()
        
        /// updateProgess
        timer = WeakTimer.timerWith(timerInterval, target: self) {[unowned self] _ in
            self.delegate?.updateProgess(self.currentTime / self.duration)
            self.updateLyric()
        }
    }
    /// 结束更新进度条
    private func stopUpProgess()
    {
        timer?.invalidate()
        timer = nil
    }
    
    /// 当前这句歌词的开始时间 < 正在播放的时间
    /// 下一句歌词的开始时间  >= 正在播放的时间
    private func updateLyric()
    {
        /// 当与下一句歌词的差值还在指定额范围内时,则不需要进行下面的遍历取值
        flag -= 2*timerInterval; guard flag <= timerInterval else { return }
        
        /// 最后一句歌词
        if currentTime >= lyrics.last?.beginTime {
            self.delegate?.updateLyric(lyrics.last!, atIndex: lyrics.count-1, nextTime: -1)
            flag = 100; return
        }
        
        var curLyricIdx = 0
        for i in 0..<lyrics.count-1 {
            if lyrics[i].beginTime < currentTime && lyrics[i+1].beginTime > currentTime {
                curLyricIdx = i; break
            }
        }
        
        var lyr = lyrics[curLyricIdx]
        let nextLrc = lyrics[curLyricIdx+1]
        var nextTime = nextLrc.beginTime
        var index = curLyricIdx
        
        /// 当当前歌词为空时,显示下一句歌词
        if lyrics[curLyricIdx].content.isEmpty {
            lyr = lyrics[0].dynamicType.init(time: currentTime, content: nextLrc.content)
            nextTime = Double(Int.max)
            index = curLyricIdx+1
        }
        
        /// 计算当前歌曲的时间(不是开始的时间)与下一句歌词的差值
        flag = (nextLrc.beginTime - currentTime) / timerInterval
        self.delegate?.updateLyric(lyr, atIndex: index, nextTime: nextTime)
   
    }
    
//MARK: - ---------------- private property ----------------

    private var player: AVAudioPlayer?
    
    private weak var timer: NSTimer?
    /// timer的间隔时间
    private let timerInterval = 0.5
    /// 记录当前播放的时间与下一句歌词开始的时间的差值
    private var flag = 0.0
    
    private override init() {}
    
}

// MARK: - AVAudioPlayerDelegate
extension PlayManager: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.playerDidFinishPlaying(successfully: flag)
    }
}


//MARK: - Tools
struct Tools
{
    /// 格式化时间
    static  func formatterTime(time: NSTimeInterval) -> String
    {
        var time = time
        time %= 3600.0
        let min = time / 60.0
        let sec = time % 60.0
        return NSString(format: "%02d:%02d", Int(min),Int(sec)) as String
    }
}






