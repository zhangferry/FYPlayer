//
//  Player.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/1/31.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import Foundation
import AVKit

private let playItemStatusKey = "status"
private let loadedTimeTimeRangsKey = "loadedTimeRanges"
private let playbackBufferEmptyKey = "playbackBufferEmpty"
private let playbackLikelyToKeepUpKey = "playbackLikelyToKeepUp"
private let timeControlStatusKey = "timeControlStatus"
private let playbackRateKey = "rate"

class AudioPlayer: NSObject {

    @objc enum PlayerState:Int, Equatable {
        case none = 0              //初始状态
        case loading            //加载状态
        case readyPlay          //开始播放
        case playing            //正在播放
        case pause              //暂停状态
        case finished           //播放完成
        case stop               //播放结束
        case failed             //加载失败
        case cached             //缓存完成
    }
    
    enum MediaType {
        case audio
        case video(UIView)
    }

    typealias PlayerStateBlock = ((PlayerState) -> Void)
    typealias BufferProgressBlock = ((Double) -> Void)
    typealias PlayProgressBlock = ((_ currentTime: TimeInterval, _ totalTime: TimeInterval) -> Void)
    typealias PlayerBufferStateBlock = ((Bool) -> Void)

    @objc var playerState: PlayerStateBlock?
    @objc var bufferProgress: BufferProgressBlock?
    @objc var playProgress: PlayProgressBlock?
    @objc var bufferState: PlayerBufferStateBlock?

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playItem: AVPlayerItem?
    
    private var audioUrl: URL?
    private var timeObserve: Any?
    ///A Boolean value that determines whether the player is pause by user
    public var isPauseByUser: Bool = false

    @objc private(set) var currentTime: TimeInterval = 0
    @objc private(set) var duration: TimeInterval = 0

    ///A Boolean value that determines whether the player is buffering
    private var isBuffering: Bool = false {
        didSet {
            self.bufferState?(isBuffering)
        }
    }

    private(set) var state: PlayerState! {
        didSet {
            print(state!.rawValue)
            self.playerState?(state)
        }
    }
    /// record player state before background
    private var stateBeforeBackground: PlayerState = .none

    ///A Boolean value that determines whether the player will play unlimited
    public var isLoops: Bool = false
    var isLocalFile: Bool = false

    ///The audio playback volume for the player, ranging from 0.0 through 1.0 on a linear
    public var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }
    
    private let type: MediaType
    /// create player need indicate mediatype
    required init(type: MediaType) {
        self.type = type
        super.init()
    }
    
    func prepare() {

    }

    ///player audio url, type of URL
    public func playMedia(with audioUrl: URL) {
        if self.player != nil {
            self.resetPlayer()
        }
        self.audioUrl = audioUrl
        configPlayer()
    }
    private func configPlayer() {
        guard let url = audioUrl else {
            return
        }
        print(url)
        self.state = .loading
        self.isBuffering = true
        let urlAsset = AVURLAsset.init(url: url)

        playItem = AVPlayerItem.init(asset: urlAsset)
        player = AVPlayer.init(playerItem: self.playItem)
        player?.volume = volume
        player?.automaticallyWaitsToMinimizeStalling = false//关闭等待最小化延迟
        player?.actionAtItemEnd = .none
        playItem?.preferredForwardBufferDuration = 1

        //保证后台可以正常播放
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback)
        try? session.setActive(true)

        addPlayObserver()
        addNotification()
    }

    /// pause, call by user
    public func pause() {
        if self.player?.status == AVPlayer.Status.readyToPlay {
            isPauseByUser = true
            player?.pause()
        }
    }
    /// play, call by user
    public func play() {
        if self.player?.status == AVPlayer.Status.readyToPlay {
            isPauseByUser = false
            player?.play()
        }
    }
    /// deinit player
    public func stopMusic() {
        resetPlayer()
    }

    //快进快退的进度
    public func seekTime(_ time : Double) {
        guard self.playItem?.status == AVPlayerItem.Status.readyToPlay else { return }
        if let absoluteUrl = self.audioUrl?.absoluteString, !absoluteUrl.contains("file"), self.state != .finished {
//            self.player?.pause()
        }
//        self.isBuffering = true
        playItem?.cancelPendingSeeks()
        player?.seek(to: CMTimeMake(value: Int64(time), timescale: 1),
                     toleranceBefore: CMTime.zero,
                     toleranceAfter: CMTime.zero,
                     completionHandler: {[weak self] (result) in
//                        self?.isBuffering = false
                        self?.player?.play()
        })
    }

    func setRate(_ rate: Float) {
        self.player?.rate = rate
    }
    //播放器重置
    private func resetPlayer() {
        NotificationCenter.default.removeObserver(self)
        removePlayObserver()
        self.player?.pause()
        self.player = nil
        self.playItem = nil
        self.isPauseByUser = false
        self.playerState?(.none)
        self.playProgress?(0,0)
        self.bufferProgress?(0)
    }

    deinit {
        resetPlayer()
    }
}
// MARK: - Block
extension AudioPlayer {
    func playState(block: PlayerStateBlock?) {
        self.playerState = block
    }

    func playProgress(block: PlayProgressBlock?) {
        self.playProgress = block
    }

    func playBufferProgress(block: BufferProgressBlock?) {
        self.bufferProgress = block
    }

    func playBufferState(block: PlayerBufferStateBlock?) {
        self.bufferState = block
    }
}
// MARK: - KVO
extension AudioPlayer {

    private func addPlayObserver() {
        playItem?.addObserver(self, forKeyPath: playItemStatusKey, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: loadedTimeTimeRangsKey, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: playbackBufferEmptyKey, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: playbackLikelyToKeepUpKey, options: .new, context: nil)
        //iOS10添加属性
        player?.addObserver(self, forKeyPath: timeControlStatusKey, options: .new, context: nil)
        player?.addObserver(self, forKeyPath: playbackRateKey, options: .new, context: nil)

        addTimeObserve()
    }

    private func removePlayObserver() {
        self.playItem?.removeObserver(self, forKeyPath: playItemStatusKey, context: nil)
        self.playItem?.removeObserver(self, forKeyPath: loadedTimeTimeRangsKey, context: nil)
        self.playItem?.removeObserver(self, forKeyPath: playbackBufferEmptyKey, context: nil)
        self.playItem?.removeObserver(self, forKeyPath: playbackLikelyToKeepUpKey, context: nil)
        self.player?.removeObserver(self, forKeyPath: timeControlStatusKey, context: nil)
        self.player?.removeObserver(self, forKeyPath: playbackRateKey, context: nil)
        self.player?.removeTimeObserver(self.timeObserve as Any)
    }

    //增加定时器
    private func addTimeObserve() {
        let interval = CMTimeMakeWithSeconds(1.0, preferredTimescale: Int32(NSEC_PER_SEC))
        self.timeObserve = self.player?.addPeriodicTimeObserver(forInterval: interval,
                                                                queue: DispatchQueue.main,
                                                                using: {[weak self] (time) in
                                                                    guard let self = self, let item = self.playItem?.seekableTimeRanges, item.count > 0, self.duration > 0 else {
                                                                        return
                                                                    }
                                                                    let currentTime = TimeInterval(CMTimeGetSeconds(time))
                                                                    self.currentTime = currentTime
                                                                    self.playProgress?(currentTime , self.duration)

        })
    }

    //KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case playItemStatusKey:
            guard let currentItem = self.player?.currentItem else {return}
            switch currentItem.status {
            case .readyToPlay:
                readyToPlay()
            case .failed:
                let error: String = currentItem.error?.localizedDescription ?? "playItem error"
                print(error)
                self.state = .failed
            case .unknown:
                self.state = .failed
            @unknown default:
                fatalError("not supported")
            }
        case loadedTimeTimeRangsKey:
            loadedTimeTimeRangs()
        case playbackBufferEmptyKey:
            bufferEmpty()
//            self.state = .loading
            print("playbackBufferEmptyKey")
        case playbackLikelyToKeepUpKey:
            // 这个值不准
            print("playbackLikelyToKeepUpKey")
            self.state = .playing
            if !self.isPauseByUser {
                self.player?.play()
            }
        case timeControlStatusKey:
            guard let timeControlStatus = self.player?.timeControlStatus,
                self.playItem?.status == AVPlayerItem.Status.readyToPlay else {
                return
            }
            switch timeControlStatus {
            case .playing:
                self.state = .playing
            case .paused:
                if self.state != .loading {
                    self.state = .pause
                }
            case .waitingToPlayAtSpecifiedRate:
                //You can refer to the reasonForWaitingToPlay property to determine why the player is currently waiting.
                print("")
            @unknown default:
                fatalError("not support")
            }
        default:
            break
        }
    }
    /// 从后台进到前台会触发该段逻辑
    private func readyToPlay() {
        
        guard !self.isPauseByUser else {
            self.pause()
            return
        }
        self.isBuffering = false
        self.player?.play()
        self.state = .readyPlay
        //currentItem may return indefinite and nan
        guard let playItem = self.playItem else {
            return
        }
        let itemDuration = playItem.asset.duration
        if itemDuration != CMTime.indefinite {
            let duration = TimeInterval(CMTimeGetSeconds(itemDuration))
            self.duration = duration
        }
    }

    private func loadedTimeTimeRangs() {
        guard let rangeValue = self.playItem?.loadedTimeRanges.first?.timeRangeValue,
            let durationTime = self.playItem?.duration else {
            return
        }
        let duration = TimeInterval(CMTimeGetSeconds(durationTime))
        let startSecond = CMTimeGetSeconds(rangeValue.start)
        let durationSecond = CMTimeGetSeconds(rangeValue.duration)
        let bufferDuration = startSecond + durationSecond
        if duration > 0 {
            self.bufferProgress?(bufferDuration / duration)
        }
    }

    private func bufferEmpty() {
        /// bufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
        guard self.playItem?.isPlaybackBufferEmpty == true, !self.isBuffering else {
            return
        }
        self.state = .loading
        self.isBuffering = true
        /// 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
        self.player?.pause()
        let popTime = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            self.isBuffering = false
            guard !self.isPauseByUser, let item = self.playItem else { return }
            if !item.isPlaybackLikelyToKeepUp {
                self.bufferEmpty()
            } else {
                self.player?.play()
            }
        }
    }
}

// MARK: - Notification
extension AudioPlayer {
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.playItem)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    //finished play
    @objc private func finishedPlaying(_ notify: Notification) {
        guard let playItem = notify.object as? AVPlayerItem else {
            return
        }
        if playItem == self.playItem {
            self.state = .finished
        }
        if self.isLoops {
            self.seekTime(0)
        }
    }

    //enter background
    @objc func enterBackground() {
        print("enter background")
        self.stateBeforeBackground = self.state
    }
    //enter foreground
    @objc func enterForeground() {
        print("enter foreground")
    }
}
