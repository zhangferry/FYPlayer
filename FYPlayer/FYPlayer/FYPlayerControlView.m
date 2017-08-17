//
//  FYPlayerControlView.m
//  FYPlayer
//
//  Created by 张飞 on 2017/7/7.
//  Copyright © 2017年 zhangferry. All rights reserved.
//

#import "FYPlayerControlView.h"
#import "FYPlayer.h"
#import "FYSlider.h"
#import <MediaPlayer/MediaPlayer.h>

@interface FYPlayerControlView ()
/** 标题 */
@property (nonatomic, strong) UILabel                 *titleLabel;
/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *startBtn;

/** topView */
@property (nonatomic, strong) UIImageView             *topImageView;
/** bottomView*/
@property (nonatomic, strong) UIImageView             *bottomImageView;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel                 *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel                 *totalTimeLabel;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *fullScreenBtn;

@property (nonatomic, strong) FYSlider                *slider;

@property (nonatomic, strong) MPVolumeView            *airPlayBtn;
/* 预览视频 */
@property (nonatomic, strong) UIImageView                  *preImageView;

@end

@implementation FYPlayerControlView

- (instancetype)init{
    self = [super init];
    if (self) {
        
        //self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        [self addSubview:self.topImageView];
        [self.topImageView addSubview:self.titleLabel];
        [self.topImageView addSubview:self.airPlayBtn];
        
        [self addSubview:self.bottomImageView];
        [self.bottomImageView addSubview:self.currentTimeLabel];
        [self.bottomImageView addSubview:self.totalTimeLabel];
        [self.bottomImageView addSubview:self.fullScreenBtn];
        [self.bottomImageView addSubview:self.startBtn];
        [self.bottomImageView addSubview:self.slider];
        
        [self addSubview:self.preImageView];
        
        
        //添加子控件约束
        [self makeSubViewConstraints];
    }
    return self;
}

/**
 添加子控件约束
 */
- (void)makeSubViewConstraints{
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_top).offset(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.leading.equalTo(self.backBtn.mas_trailing).offset(5);
        make.leading.equalTo(self.topImageView.mas_leading).offset(10);
        make.top.equalTo(self.topImageView.mas_top).offset(10);
        make.trailing.equalTo(self.topImageView.mas_trailing).offset(-10);
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomImageView.mas_leading).offset(5);
        make.bottom.equalTo(self.bottomImageView.mas_bottom).offset(-5);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.startBtn.mas_trailing).offset(-3);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(45);//30
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-5);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.fullScreenBtn.mas_leading).offset(3);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(3);
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(3);
        make.centerY.equalTo(self.startBtn);
    }];
    
    [self.preImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(150, 150));
    }];
    
    [self.airPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topImageView.mas_right).offset(-5);
        make.centerY.equalTo(self.topImageView);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    //[[UIApplication sharedApplication] sendAction:NSSelectorFromString(@"_displayAudioRoutePicker") to:self.airPlayBtn from:self.topImageView forEvent:nil];
    
}

/**
 点击播放按钮
 */
- (void)playBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(fy_playerPauseAction)]) {
        [self.delegate fy_playerPauseAction];
    }
}


/**
 点击全屏按钮
 */
- (void)fullScreenBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(fy_playerFullScreenAction)]) {
        [self.delegate fy_playerFullScreenAction];
    }
}

- (void)sliderTouchBegan:(FYSlider *)slider{
    _preImageView.alpha = 1;
    
}

- (void)sliderTouchChange:(FYSlider *)slider{
    if ([self.delegate respondsToSelector:@selector(fy_playerDraggingSlider:)]) {
        [self.delegate fy_playerDraggingSlider:slider.value];
    }
}

- (void)sliderTouchEnd:(FYSlider *)slider{
    if ([self.delegate respondsToSelector:@selector(fy_playerDraggedSlider:)]) {
        [self.delegate fy_playerDraggedSlider:slider.value];
    }
    _preImageView.alpha = 0;
}

- (void)fy_playerPlayingState:(BOOL)state{
    self.startBtn.selected = state;
}

/** 当前播放时间 */
- (void)fy_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime value:(CGFloat)value{
    
    NSInteger curMin = currentTime/60;
    NSInteger curSec = currentTime%60;
    
    NSInteger durMin = totalTime/60;
    NSInteger durSec = totalTime%60;
    
    //如果正在拖动，不自动进行
    self.slider.value = value;
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd",curMin,curSec];
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd",durMin,durSec];
    
}

/**
 显示快进预览图

 @param time 当前时间
 @param image 预览图片
 */
- (void)fy_playerDraggedTime:(NSInteger)time preImage:(UIImage *)image{
    self.preImageView.image = image;
    
//    [UIView animateWithDuration:0.5 animations:^{
//        _preImageView.alpha = 0;
//    }];
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
    return _titleLabel;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:FYPlayerImage(@"FYPlayer_play") forState:UIControlStateNormal];
        [_startBtn setImage:FYPlayerImage(@"FYPlayer_pause") forState:UIControlStateSelected];
        [_startBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView                        = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.alpha                  = 1;
        _topImageView.image                  = FYPlayerImage(@"FYPlayer_top_shadow");
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.alpha                  = 1;
        _bottomImageView.image                  = FYPlayerImage(@"FYPlayer_bottom_shadow");
    }
    return _bottomImageView;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel               = [[UILabel alloc] init];
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (FYSlider *)slider{
    
    if (!_slider) {
        _slider = [[FYSlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        [_slider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(sliderTouchChange:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        [_slider setThumbImage:FYPlayerImage(@"FYPlayer_slider") forState:UIControlStateNormal];
    }
    return _slider;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:FYPlayerImage(@"FYPlayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn setImage:FYPlayerImage(@"FYPlayer_shrinkscreen") forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

- (UIImageView *)preImageView{
    if (!_preImageView) {
        _preImageView = [[UIImageView alloc] init];
        
        _preImageView.contentMode = UIViewContentModeScaleAspectFit;
        _preImageView.alpha = 0;

    }
    return _preImageView;
}

- (MPVolumeView *)airPlayBtn{
    if (!_airPlayBtn) {
        _airPlayBtn = [[MPVolumeView alloc] init];
        _airPlayBtn.showsRouteButton = YES;
        _airPlayBtn.showsVolumeSlider = NO;
        
    }
    return _airPlayBtn;
}

@end
