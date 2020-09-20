//
//  MainViewController.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/1/31.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    var playerView: FYPlayerView!
    var player: AudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main"
        view.backgroundColor = UIColor.white

        setupUI()
    }
    
    private func setupUI() {
        let videoView = UIView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width * 9 / 16))
        videoView.backgroundColor = UIColor.lightGray
        view.addSubview(videoView)

        //playerView
        playerView = FYPlayerView()

        let videoModel = FYVideoModel()
        videoModel.title = "电影鉴赏"
        videoModel.videoUrl = URL(string: "https://video.pearvideo.com/mp4/adshort/20200202/cont-1647756-14860863_adpkg-ad_hd.mp4")

        player = AudioPlayer.init()
        player.playMedia(with: videoModel.videoUrl)
        
        
//        playerView.player(with: videoView, videoModel: videoModel)
    }
}
