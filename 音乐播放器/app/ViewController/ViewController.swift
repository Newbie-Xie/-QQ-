//
//  ViewController.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/21.
//  Copyright © 2016年 2期. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import LocalAuthentication

class ViewController: UIViewController {
    
    //MARK: --------------- 通用 ---------------
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var progessSlider: UISlider!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    
    //MARK: --------------- 竖屏 ---------------
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var vCenterImageV: UIImageView!
    @IBOutlet weak var vLyricLabel: LyricLabel!
    
    @IBOutlet weak var vCenterView: UIView!
    @IBOutlet weak var vLyricView: LyricView! {
        didSet{ vLyricView.delegate = self }
    }
    
    //MARK: --------------- 横屏 ---------------
    @IBOutlet weak var hCenterImageV: UIImageView!
    @IBOutlet weak var hLyricLabel: LyricLabel!
    
    
    //MARK: - Private Property
    /// 歌曲模型数组
    private let models = MusicModal.modals()
    private weak var _playManager: PlayManager! = PlayManager.manager
    private var isDragSlider = false
    private weak var timer: NSTimer?
    /// 当前播放歌曲的index
    private var currentIndex = 0

    /// 是否竖屏
    private var isVertically = true
    
    /// 储存当前歌词的开始时间，以及和下一句歌词的差值
    private var lyricTime = (0.0, 1.0)
    
    /// 1.使用后台，需要现在capabilites设置后台模式
    /// 2.在appdelegate开启后台监听
    /// 2.设置播放类型
    
    
    //MARK: - Override Method
    override func viewDidLoad()
    {
        super.viewDidLoad()
        laodView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 指纹登录
        view.alpha = 0
        let context = LAContext()
        let error = NSErrorPointer()
        guard context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: error) else { return }
        
        context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "请按下你的小指头") { (succeed, _) in
            if succeed { self.view.alpha = 1.0; print("验证成功") }
            else{ print("验证失败") }
        }
    }
    
    private func laodView() {
        
        isVertically = view.bounds.width <= view.bounds.height
        
        timer = WeakTimer.timerWith(0.1, target: self){ [unowned self]_ in
            /// 旋转中间的图片
            self.vCenterImageV.transform = CGAffineTransformRotate(self.vCenterImageV.transform, CGFloat(M_PI_4) * 0.05)
            
            let progess = (self._playManager.currentTime - self.lyricTime.0) / self.lyricTime.1
            /// 更新歌词的进度(颜色)
            if self.isVertically {
                self.vLyricLabel.progess = progess
                self.vLyricView.currentLabel.progess = progess
            }else{
                self.hLyricLabel.progess = progess
            }
        }
        timer?.fireDate = NSDate.distantFuture()
        
        _playManager.delegate = self
        
        /// 添加毛玻璃背景
        addBlurBackGroundView()
        
        /// 先加载第一首音乐
        changMusic()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        vCenterImageV.layer.cornerRadius = vCenterImageV.bounds.height * 0.5
        vCenterImageV.layer.masksToBounds = true
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        isVertically = size.width <= size.height
    }
    
    //MARK: - StoryBoard Method
    @IBAction func play() {
        playBtn.selected = !playBtn.selected
        if playBtn.selected {
            _playManager.play()
            timer?.fireDate = NSDate.distantPast()
        }else{
            _playManager.pause()
            timer?.fireDate = NSDate.distantFuture()
        }
    }
    
    @IBAction func previous() {
        currentIndex -= 1
        if currentIndex < 0 { currentIndex = models.count - 1 }
        changMusic(); play()
    }
    
    @IBAction func next() {
        currentIndex += 1
        if currentIndex >= models.count { currentIndex = 0 }
        changMusic(); play()
    }
    
    @IBAction func touchDownSlider() { isDragSlider = true }
    
    @IBAction func changProgress() {
        currentTime.text = Tools.formatterTime(Double(progessSlider.value) * _playManager.duration)
    }
    
    @IBAction func touchUpSlider() {
        isDragSlider = false
        _playManager.currentTime = Double(progessSlider.value) * _playManager.duration
        
        /// 如果是暂停状态，则开始播放
        if !playBtn.selected { play() }
    }
    
    // MARK: - Private Method
    private func changMusic() {
        
        progessSlider.value = 0.0
        vCenterImageV.transform = CGAffineTransformIdentity
        
        let model = models[currentIndex]
        singerLabel.text = model.singer
        albumLabel.text = model.album
        self.title = model.name
        let image = UIImage(named: model.imageName)
        bgImageView.image = image
        vCenterImageV.image = image
        hCenterImageV.image = image
        
        
        playBtn.selected = false
        _playManager.preparePlay(model)
        
        vLyricView.index = 0
        /// 赋值歌词数组
        vLyricView.lyrics = _playManager.lyrics.lazy.map{ $0.content }
        
        /// 在准备歌曲后面获取时间
        currentTime.text = Tools.formatterTime(_playManager.currentTime)
        totalTime.text = Tools.formatterTime(_playManager.duration)

    }
    
    /// 更新锁屏界面歌词
    private func updateLockScreenLyric(lyr: LyricProtocol)
    {
        /// 锁屏界面核心类
        let media = MPNowPlayingInfoCenter.defaultCenter()
        let music = models[currentIndex]
        
        // MPMediaItemPropertyAlbumTitle        // 专辑名
        // MPMediaItemPropertyAlbumTrackCount   // 专辑中歌曲的数量
        // MPMediaItemPropertyAlbumTrackNumber  // 专辑编号
        // MPMediaItemPropertyArtist            // 歌手
        // MPMediaItemPropertyArtwork           // 锁屏界面图片
        // MPMediaItemPropertyComposer          // 作曲家
        // MPMediaItemPropertyPlaybackDuration  // 歌曲持续时间
        // MPMediaItemPropertyTitle             // 歌曲名
        // MPNowPlayingInfoPropertyElapsedPlaybackTime  // 歌曲当前播放的时间
        
        let artWork = MPMediaItemArtwork(image: UIImage(named: music.imageName)!)
        
        media.nowPlayingInfo = [MPMediaItemPropertyAlbumTitle : music.album,
                                MPMediaItemPropertyArtist: music.singer,
                                MPMediaItemPropertyArtwork : artWork,
                                MPMediaItemPropertyPlaybackDuration : _playManager.duration,
                                MPMediaItemPropertyTitle : music.name,
                                MPNowPlayingInfoPropertyElapsedPlaybackTime : _playManager.currentTime]
        
    }
    
    /// 添加毛玻璃背景
    private func addBlurBackGroundView() {
        
        /// 第一种方式
        let bgNavBar = UINavigationBar(frame: view.bounds)
        bgNavBar.barStyle = .Black
        bgImageView.addSubview(bgNavBar)
        
        /// 第二种方式
//        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
//        blurView.frame = view.bounds
//        blurView.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
//        bgImageView.addSubview(blurView);
        
    }
    
    deinit { print("ViewController释放了") }
}

//MARK: - PlayManagerDelegate
extension ViewController: PlayManagerDelegate
{
    /// 更新进度条
    func updateProgess(progess: Double)
    {
        /// 当进度条处于拖拽时,则不要更新
        if !isDragSlider {
            progessSlider.value = Float(progess)
            currentTime.text = Tools.formatterTime(progess * _playManager.duration)
        }
    }
    /// 更新歌词
    func updateLyric(lyric: LyricProtocol, atIndex: Int, nextTime: Double) {
        
        /// 更新锁屏歌词
        updateLockScreenLyric(lyric)
        
        /// 横竖屏都要赋值,避免切换时,歌词内容没更新
        vLyricLabel.text = lyric.content
        hLyricLabel.text = lyric.content
        
        vLyricView.currentLabel.progess = 0
        vLyricView.index = atIndex
        
        if nextTime < 0 {
            lyricTime = (lyric.beginTime, 3.0)
        }else  {
            lyricTime = (lyric.beginTime, nextTime - lyric.beginTime)
        }
    }
    
    func playerDidFinishPlaying(successfully flag: Bool) { next() }
}


extension ViewController: LyricViewDelegate
{
    func lyricView(view: LyricView, didHorizScroll offset: CGFloat) {
        vCenterView.alpha = 1 - offset / view.bounds.width
    }
}








