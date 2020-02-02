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
        let mainNav = UINavigationController.init(rootViewController: mainVc)
        let videoListVc = VideoListViewController()
        let videoNav = UINavigationController.init(rootViewController: videoListVc)
        let musicVc = MusicViewController()
        let musicNav = UINavigationController.init(rootViewController: musicVc)
        
        let tabbarVc = UITabBarController()
        tabbarVc.viewControllers = [mainNav, videoListVc, musicNav]
        self.window?.rootViewController = tabbarVc
        self.window?.makeKeyAndVisible()
    }
}
