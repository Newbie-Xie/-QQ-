//
//  AppDelegate.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/21.
//  Copyright © 2016年 2期. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
    
        return true
    }


    func applicationDidEnterBackground(application: UIApplication) {
        /// 进图后台，开始加载远程事件
        application.beginReceivingRemoteControlEvents()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        /// 进入前台，停止接受
        application.endReceivingRemoteControlEvents()
    }




}

