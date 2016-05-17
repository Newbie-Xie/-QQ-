//
//  WeakTimer.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/22.
//  Copyright © 2016年 2期. All rights reserved.
//

import Foundation

//MARK: - WeakTimer
public struct WeakTimer
{
    /// 不对target强引用,不阻塞主线程,不需要在deinit中释放
    public static func timerWith(timeInterval: NSTimeInterval, target: AnyObject, selector: Selector, userInfo: AnyObject? = nil, repeats: Bool = true) -> NSTimer
    {
        let proxy = WeakProxy()
        proxy.target = target
        proxy.selector = selector
        
        let timer = NSTimer(timeInterval: timeInterval, target: proxy, selector: #selector(WeakProxy.fire), userInfo: userInfo, repeats: repeats)
        
        GCD.async_globle {
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            NSRunLoop.currentRunLoop().run()
        }
        
        proxy.timer = timer
        return timer
    }
    
    /// 不对target强引用,不阻塞主线程,不需要在deinit中释放
    public static func timerWith(timeInterval: NSTimeInterval, target: AnyObject, repeats: Bool = true, _ closure: NSTimer? -> Void) -> NSTimer
    {
        let proxy = WeakProxy()
        proxy.target = target
        proxy.closour = closure
        
        let timer = NSTimer(timeInterval: timeInterval, target: proxy, selector: #selector(WeakProxy.executeClosure), userInfo: nil, repeats: repeats)
        
        GCD.async_globle {
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            NSRunLoop.currentRunLoop().run()
        }
        
        proxy.timer = timer
        return timer
    }
}

//MARK: - WeakProxy
private final class WeakProxy: NSObject
{
    private weak var target: AnyObject? = nil
    private var selector: Selector?
    private var closour: (NSTimer?) -> Void = {_ in}
    private weak var timer: NSTimer?
    
    @objc func fire() -> Void {
        if target != nil && selector != nil
            && target!.respondsToSelector(selector!)
        {
            GCD.async_main{ self.target?.performSelector(self.selector!) }
        }else {
            self.invalidateTimer()
        }
    }
    
    @objc func executeClosure() -> Void {
        if target == nil {
            self.invalidateTimer(); return
        }
        
        unowned let weakSelf = self
        GCD.async_main{ self.closour(weakSelf.timer) }
    }
    
    private func invalidateTimer() -> Void {
        if timer != nil { timer!.invalidate() }
        timer = nil
    }
    
    deinit {
        debugPrint("timer释放了")
    }
}

public struct GCD
{
    public static func async_main(clo: dispatch_block_t){
        dispatch_async(dispatch_get_main_queue(), clo)
    }
    public static func async_globle(clo: dispatch_block_t){
        dispatch_async(dispatch_get_global_queue(0, 0), clo)
    }
}