//
//  FYPlayer.h
//  FYPlayer
//
//  Created by 张飞 on 2017/7/7.
//  Copyright © 2017年 zhangferry. All rights reserved.
//

// 屏幕的宽
#define ScreenWidth             [[UIScreen mainScreen] bounds].size.width
// 屏幕的高
#define ScreenHeight            [[UIScreen mainScreen] bounds].size.height
// 图片路径
#define FYPlayerSrcName(file)   [@"FYPlayer.bundle" stringByAppendingPathComponent:file]

#define FYPlayerImage(file)     [UIImage imageNamed:FYPlayerSrcName(file)]

#import "FYPlayerView.h"
#import "FYPlayerControlView.h"
#import "FYVideoModel.h"
#import "Masonry.h"
