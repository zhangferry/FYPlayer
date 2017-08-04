//
//  FYPlayer.h
//  FYPlayer
//
//  Created by 张飞 on 2017/7/7.
//  Copyright © 2017年 zhangferry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYPlayer.h"
#import "FYVideoModel.h"

typedef NS_ENUM(NSInteger, FYPlayerState){
    FYPlayerStatePlaying = 1,
    FYPlayerStatePause,
    FYPlayerStateFailed,
    FYPlayerStateBuffering
};

@protocol FYPlayerDelegate <NSObject>
/**播放完成*/
- (void)fy_playerMovieFinished;
/**播放失败*/
- (void)fy_playerMovieFailed:(NSError *)error;

@end

@interface FYPlayerView : UIView

@property (nonatomic, weak) id<FYPlayerDelegate> delegate;

@property (nonatomic, assign) FYPlayerState state;

//加载播放
- (void)playerWithView:(UIView *)view videoModel:(FYVideoModel *)videoModel;

- (void)play;

- (void)pause;

@end
