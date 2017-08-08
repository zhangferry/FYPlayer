//
//  FYPlayer.m
//  FYPlayer
//
//  Created by 张飞 on 2017/7/7.
//  Copyright © 2017年 zhangferry. All rights reserved.
//

#import "FYPlayerView.h"
#import "FYPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>

@interface FYPlayerView ()<FYPlayerControlViewDelegate>

/** 播放器相关配置 */
@property (nonatomic, strong) AVPlayer            *player;
@property (nonatomic, strong) AVPlayerLayer       *playerLayer;
@property (nonatomic, strong) AVPlayerItem        *playerItem;
@property (nonatomic, strong) AVURLAsset          *urlAsset;
@property (nonatomic, strong) id                  timeObserve;

@property (nonatomic, strong) FYVideoModel        *videoModel;
@property (nonatomic, strong) FYPlayerControlView *controlView;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, strong) UIView *fatherView;

@property (nonatomic, assign, getter=isAirPlayVideoAvtive) BOOL airPlayEnabled;

@property (nonatomic, strong) UIWindow *externalWindow;

@end

@implementation FYPlayerView

- (id)init{
    self = [super init];
    if (self) {
        self.isFullScreen = NO;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

//加载播放
- (void)playerWithView:(UIView *)view videoModel:(FYVideoModel *)videoModel{
    _fatherView = view;
    [self addPlayerToFatherView:view];
    
    self.videoModel = videoModel;
}

/**
 player添加到父视图上
 */
- (void)addPlayerToFatherView:(UIView *)view{
    if (self.window) {
        [self removeFromSuperview];
    }
    
    [view addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsZero);
    }];
    
    if (!_controlView) {
        _controlView = [[FYPlayerControlView alloc] init];
        _controlView.delegate = self;
        [self addSubview:_controlView];
        
        [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
    }
   
}

- (void)addPlayerItemObserVer{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)addNotification{
    //检测设备方向要设置这个
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    //状态栏方向变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStateBarOrientationChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    //播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerMovieFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalScreenDidConnect:) name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalScreenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
    
}

- (void)play{
    [self.controlView fy_playerPlayingState:YES];
    [_player play];
}

- (void)pause{
    [self.controlView fy_playerPlayingState:NO];
    [_player pause];
}

- (void)setVideoModel:(FYVideoModel *)videoModel{
    _videoModel = videoModel;
    
    [self configFYPlayer];
}

- (void)setState:(FYPlayerState)state{
    _state = state;
    if (state == FYPlayerStateFailed) {
        NSError *error = [self.playerItem error];
        if ([self.delegate respondsToSelector:@selector(fy_playerMovieFailed:)]) {
            [self.delegate fy_playerMovieFailed:error];
        }
        
    }
    
}


/**
 配置播放器
 */
- (void)configFYPlayer{
    self.urlAsset = [AVURLAsset assetWithURL:self.videoModel.videoUrl];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player= [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    //要把playerlayer加到视图layer之上
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    [self addPlayerItemObserVer];
    
    [self addNotification];
    //添加计时器
    [self addTimeObserve];
    
    [self settingAirPlay];
    
}

- (void)settingAirPlay{
    
    if (self.airPlayEnabled) {
        [self.player setAllowsExternalPlayback:YES];
        [self.player setUsesExternalPlaybackWhileExternalScreenIsActive:YES];
        
        [self.player removeObserver:self forKeyPath:@"airPlayVideoActive"];
        [self.player addObserver:self forKeyPath:@"airPlayVideoActive" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)resetPlayer{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    //移除监听
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
}

/**
 是否支持airplay
 */
- (BOOL)isAirPlayVideoAvtive{
    return [AVPlayer instancesRespondToSelector:@selector(isAirPlayVideoActive)] && self.player.externalPlaybackActive;
}

/**
 添加计时器
 */
- (void)addTimeObserve{
    __weak __typeof(self) WeakSelf = self;
    
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        
        AVPlayerItem *item = WeakSelf.playerItem;
        //两种方式求绝对时间
        NSInteger currentTime = item.currentTime.value/item.currentTime.timescale;
        NSInteger totalTime   = (NSInteger)CMTimeGetSeconds(item.duration);
        CGFloat value = CMTimeGetSeconds(item.currentTime)/CMTimeGetSeconds(item.duration);
        [WeakSelf.controlView fy_playerCurrentTime:currentTime totalTime:totalTime value:value];
    }];
}

/**
 KVO
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (_playerItem.status) {
                case AVPlayerItemStatusReadyToPlay:
                    //推荐将视频播放放在这里
                    [self play];
                    break;
                    
                case AVPlayerItemStatusUnknown:
                    NSLog(@"AVPlayerItemStatusUnknown");
                    break;
                    
                case AVPlayerItemStatusFailed:
                    NSLog(@"AVPlayerItemStatusFailed");
                    self.state = FYPlayerStateFailed;
                    break;
                default:
                    break;
            }
            
        }
    }else if ([object isKindOfClass:[AVPlayer class]]){
        if ([keyPath isEqualToString:@"rate"]) {
            AVPlayer *player = (AVPlayer *)object;
            if (player.rate == 0) {
                //正在暂停
                self.state = FYPlayerStatePause;
            }else if (player.rate == 1){
                self.state = FYPlayerStatePlaying;
            }
        }else if ([keyPath isEqualToString:@"airPlayVideoActive"]){
            
            BOOL airPlayVideoActive = self.player.externalPlaybackActive;
            NSLog(@"airPlayActive状态变化%d",airPlayVideoActive);
        }
        
    }
}

/**
 播放完成的通知
 */
- (void)playerMovieFinish:(NSNotification *)noti{
    if ([self.delegate respondsToSelector:@selector(fy_playerMovieFinished)]) {
        [self.delegate fy_playerMovieFinished];
    }
}

#pragma mark - FYPlayerControlViewDelegate

- (void)fy_playerFullScreenAction{
    if (!self.isFullScreen) {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }else{
            [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        }
        self.isFullScreen = YES;
        
    }else{
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        self.isFullScreen = NO;
    }
}

- (void)fy_playerPauseAction{
    if (self.state == FYPlayerStatePlaying) {
        [self pause];
    }else if (self.state == FYPlayerStatePause){
        [self play];
    }
    
}

- (void)fy_playerDraggedSlider:(CGFloat)value{
    
    NSInteger drageSecond = CMTimeGetSeconds(self.playerItem.duration)*value;
    [self seekToTime:drageSecond completionHandler:nil];
}

- (void)seekToTime:(NSInteger)drageSecond completionHandler:(void (^)(BOOL))completionHandler{
    
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        __weak __typeof(self) weakSelf = self;
        
        [self.player seekToTime:CMTimeMake(drageSecond, 1) toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
            if (completionHandler) {
                completionHandler(finished);
            }
            [weakSelf.player play];
        }];
    }
    
}

#pragma mark - 全屏设置

- (void)onDeviceOrientationChange{
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}

- (void)onStateBarOrientationChange{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        case UIInterfaceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIInterfaceOrientationPortrait:
            NSLog(@"界面直立");
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@"界面直立，上下颠倒");
            break;
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"界面朝左");
            break;
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"界面朝右");
            break;
        default:
            break;
    }
}

/**
 屏幕旋转方向

 @param orientation 需要旋转的方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        //横屏状态
        [self setOrientation:orientation];
        
    }else if(orientation == UIInterfaceOrientationPortrait){
        //竖屏装态
        [self addPlayerToFatherView:_fatherView];
        [self setOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)setOrientation:(UIInterfaceOrientation)orientation{
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == orientation) {return;}
    if (orientation != UIInterfaceOrientationPortrait) {
        
        if (currentOrientation == UIInterfaceOrientationPortrait) {
            [self removeFromSuperview];
            
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(ScreenHeight));
                make.height.equalTo(@(ScreenWidth));
                make.center.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        }
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.transform = CGAffineTransformIdentity;
    self.transform = [self getTransformRotationAngle];
    [UIView commitAnimations];
}

/**
 * 获取变换的旋转角度
 *
 * @return 角度
 */
- (CGAffineTransform)getTransformRotationAngle {
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

#pragma mark - airplay
- (void)externalScreenDidConnect:(NSNotification *)noti{
    UIScreen *screen = [noti object];
    [self setupExternalWindowForScreen:screen];
    
    //[self inserts];
    UILabel *airPlayLabel = [[UILabel alloc] init];
    airPlayLabel.text = @"AirPlay";
    
    airPlayLabel.textColor = [UIColor whiteColor];
    airPlayLabel.font = [UIFont boldSystemFontOfSize:50];
    
    [self.externalWindow addSubview:airPlayLabel];
    
    [airPlayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.externalWindow);
        make.width.height.mas_equalTo(50);
    }];
}

- (void)externalScreenDidDisconnect:(NSNotification *)noti{
    [self setupExternalWindowForScreen:nil];
}

- (void)setupExternalWindowForScreen:(UIScreen *)screen {
    if (screen != nil) {
        self.externalWindow = [[UIWindow alloc] initWithFrame:screen.applicationFrame];
        self.externalWindow.hidden = NO;
        self.externalWindow.clipsToBounds = YES;
        
        if (screen.availableModes.count > 0) {
            UIScreenMode *desiredMode = [screen.availableModes objectAtIndex:screen.availableModes.count-1];
            screen.currentMode = desiredMode;
        }
        
        self.externalWindow.screen = screen;
        [self.externalWindow makeKeyAndVisible];
    } else {
        [self.externalWindow removeFromSuperview];
        [self.externalWindow resignKeyWindow];
        self.externalWindow.hidden = YES;
        self.externalWindow = nil;
    }
}


@end
