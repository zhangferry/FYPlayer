//
//  MainViewController.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/1/31.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var playerView: FYPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main"
        view.backgroundColor = UIColor.white
        
        var set = Set.init([1, 2, 3])

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
        videoModel.videoUrl = URL(string: "http://baobab.wdjcdn.com/14573563182394.mp4")

        playerView.player(with: videoView, videoModel: videoModel)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
