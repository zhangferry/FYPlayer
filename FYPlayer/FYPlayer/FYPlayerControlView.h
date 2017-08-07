//
//  FYPlayerControlView.h
//  FYPlayer
//
//  Created by 张飞 on 2017/7/7.
//  Copyright © 2017年 zhangferry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FYPlayerControlViewDelegate <NSObject>

- (void)fy_playerFullScreenAction;

- (void)fy_playerPauseAction;
/** 拖动进度条 */
- (void)fy_playerDraggedSlider:(CGFloat)value;

@end

@interface FYPlayerControlView : UIView

@property (nonatomic, weak) id<FYPlayerControlViewDelegate> delegate;
/** 播放状态 */
- (void)fy_playerPlayingState:(BOOL)state;
/** 当前播放时间 */
- (void)fy_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime value:(CGFloat)value;
/** 当前缓存 */
- (void)fy_playerSetProgress:(CGFloat)progress;

@end
