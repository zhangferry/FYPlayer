//
//  AppDelegate.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/1/31.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        let mainVc = MainViewController()
        mainVc.tabBarItem.title = "Main"
        let mainNav = UINavigationController.init(rootViewController: mainVc)
        
        let videoListVc = VideoListViewController()
        let videoNav = UINavigationController.init(rootViewController: videoListVc)
        videoNav.tabBarItem.title = "VideoList"
        
        let musicVc = MusicViewController()
        let musicNav = UINavigationController.init(rootViewController: musicVc)
        musicNav.tabBarItem.title = "MusicList"
        
        let tabbarVc = UITabBarController()
        tabbarVc.viewControllers = [mainNav, videoNav, musicNav]
        self.window?.rootViewController = tabbarVc
        self.window?.makeKeyAndVisible()
    }
}
