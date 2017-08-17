//
//  MainViewController.m
//  FYPlayer
//
//  Created by 张飞 on 2017/7/7.
//  Copyright © 2017年 zhangferry. All rights reserved.
//

#import "MainViewController.h"
#import "FYPlayer.h"

@interface MainViewController ()

@property (nonatomic, strong) FYPlayerView *playerView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"FYBundle" ofType:@"bundle"];
    
    UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth * 9/16)];
    videoView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:videoView];
    
    //playerView
    self.playerView = [[FYPlayerView alloc] init];

    FYVideoModel *videoModel = [[FYVideoModel alloc] init];
    videoModel.title = @"电影鉴赏";
    videoModel.videoUrl = [NSURL URLWithString:@"http://baobab.wdjcdn.com/14573563182394.mp4"];
    
    [self.playerView playerWithView:videoView videoModel:videoModel];
    //[self.playerView play];
}


- (BOOL)shouldAutorotate{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
