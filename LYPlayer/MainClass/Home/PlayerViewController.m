//
//  PlayerViewController.m
//  LYPlayer
//
//  Created by yun on 2018/7/3.
//  Copyright © 2018年 yun. All rights reserved.
//

#import "PlayerViewController.h"
#import "LYPlayer.h"

@interface PlayerViewController ()<LYPlayerViewDelegate>

@property(nonatomic,strong) LYPlayerView *playerView;


@end

@implementation PlayerViewController

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *fatherView = [[UIView alloc] init];
    fatherView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fatherView];
    [fatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    
    self.playerView = [[LYPlayerView alloc] init];
    _playerView.delegate = self;
    [fatherView addSubview:_playerView];
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(fatherView);
    }];
    
    LYPlayerModel *model = [[LYPlayerModel alloc] init];
    model.title = @"自拍视频";
    model.videoURL = [NSURL URLWithString:@"http://flv3.bn.netease.com/tvmrepo/2018/6/H/9/EDJTRBEH9/SD/EDJTRBEH9-mobile.mp4"];
    model.fatherView = fatherView;
    [_playerView defaultControlViewWithPlayerModel:model];
}


// 退出播放器
- (void)ly_exitPlayer{
    
    [self.navigationController popViewControllerAnimated:YES];
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
