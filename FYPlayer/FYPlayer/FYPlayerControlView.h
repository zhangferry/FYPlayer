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

@end

@interface FYPlayerControlView : UIView

@property (nonatomic, weak) id<FYPlayerControlViewDelegate> delegate;

- (void)fy_playerPlayingState:(BOOL)state;

@end
