# LYPlayer
基于AVPlayer视频播放器

#### 1、介绍

本文参考任子丰的[ZFPlayer](https://github.com/renzifeng/ZFPlayer)<br/>

功能：支持竖屏、横屏全屏播放

目录：

1、LYPlayer：头文件<br/>
2、LYPlayerConfiguration：一些配置宏定义<br/>
3、LYPlayerModel：播放器参数模型<br/>
4、LYPlayerView：播放器主体View<br/>
5、LYPlayerControlView：播放器控制层<br/>
6、LYPlayer.bundle：图片资源<br/>

#### 2、使用方法

```
    // 播放器父视图（播放器最好是基于一个父视图，播放器View大小与父视图一样，这个在横竖屏时设置有用）
    UIView *fatherView = [[UIView alloc] init];
    fatherView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fatherView];
    [fatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    // 播放器View
    self.playerView = [[LYPlayerView alloc] init];
    // 代理
    self.playerView = [[LYPlayerView alloc] init];
    _playerView.delegate = self;
    [fatherView addSubview:_playerView];
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(fatherView);
    }];
    
    // 播放器模型参数
    LYPlayerModel *model = [[LYPlayerModel alloc] init];
    model.title = @"自拍视频";
    model.videoURL = [NSURL URLWithString:@"http://flv3.bn.netease.com/tvmrepo/2018/6/H/9/EDJTRBEH9/SD/EDJTRBEH9-mobile.mp4"];
    model.fatherView = fatherView;
    [_playerView defaultControlViewWithPlayerModel:model];

```

