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

@interface FYPlayerView : UIView

//加载播放
- (void)playerWithView:(UIView *)view videoModel:(FYVideoModel *)videoModel;

- (void)play;

@end
