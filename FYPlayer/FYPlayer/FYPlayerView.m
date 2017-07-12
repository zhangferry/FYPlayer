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

@interface FYPlayerView ()

/** 播放器相关配置 */
@property (nonatomic, strong) AVPlayer            *player;
@property (nonatomic, strong) AVPlayerLayer       *playerLayer;
@property (nonatomic, strong) AVPlayerItem        *playerItem;
@property (nonatomic, strong) AVURLAsset          *urlAsset;

@property (nonatomic, strong) FYVideoModel        *videoModel;
@property (nonatomic, strong) FYPlayerControlView *controlView;

@end

@implementation FYPlayerView


- (void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

//加载播放
- (void)playerWithView:(UIView *)view videoModel:(FYVideoModel *)videoModel{
    
    [self addPlayerToFatherView:view];
    
    self.videoModel = videoModel;
}

/**
 player添加到父视图上
 */
- (void)addPlayerToFatherView:(UIView *)view{
    [view addSubview:self];
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsZero);
    }];
    
    if (!_controlView) {
        _controlView = [[FYPlayerControlView alloc] init];
        [self addSubview:_controlView];
        
        [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
    }
   
    
    
}

- (void)addPlayerItemObserVer{
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)play{
    [_player play];
}

- (void)setVideoModel:(FYVideoModel *)videoModel{
    _videoModel = videoModel;
    
    [self configFYPlayer];
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
}

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
                default:
                    break;
            }
            
        }
    }
}

@end
