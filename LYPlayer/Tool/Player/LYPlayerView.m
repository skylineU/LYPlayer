//
//  LYPlayerView.m
//  LYPlayer
//
//  Created by yun on 2018/5/14.
//  Copyright © 2018年 yun. All rights reserved.
//

#import "LYPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "LYPlayerControlView.h"
#import "LYPlayerConfiguration.h"
#import "Masonry.h"

@interface LYPlayerView ()<LYPlayerControlViewDelegate,UIGestureRecognizerDelegate>
// 控制面板
@property(nonatomic,strong) LYPlayerControlView *controlView;
// 视频参数
@property(nonatomic,strong) LYPlayerModel *playModel;

// 播放器参数
@property(nonatomic,strong) AVURLAsset *asset;
@property(nonatomic,strong) AVPlayerItem *playerItem;
@property(nonatomic,strong) AVPlayer *player;
@property(nonatomic,strong) AVPlayerLayer *playerLayer;

// 时间观察
@property(nonatomic,strong) id timeObserver;

@property(nonatomic,strong) NSURL *videoURL;
// 是否自动播放
@property(nonatomic,assign,getter=isAutoPlay) BOOL autoPlay;
@property(nonatomic,assign) LYPlayerState state;// 播放状态

/// 相关参数

@property(nonatomic,assign,getter=isEnterBackgroud) BOOL enterBackgroud;// 是否进入后台
@property(nonatomic,assign,getter=isFullScreen) BOOL fullScreen;// 是否全屏




@end

@implementation LYPlayerView

- (void)dealloc{
    NSLog(@"%s",__func__);
    // 移除相关观察者
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)defaultControlViewWithPlayerModel:(LYPlayerModel *)playerModel{
    // 设置默认控制面板
    LYPlayerControlView *controlView = [[LYPlayerControlView alloc] init];
    controlView.delegate = self;
    [self playerControlView:controlView playerModel:playerModel];
}

- (void)playerControlView:(LYPlayerControlView *)controlView playerModel:(LYPlayerModel *)playerModel{
    if (controlView) {
        self.controlView = controlView;
        [self addSubview:self.controlView];
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    self.playModel = playerModel;
}

#pragma mark -- setter

- (void)setPlayModel:(LYPlayerModel *)playModel{
    _playModel = playModel;
    self.videoURL = playModel.videoURL;
    [self.controlView ly_setInfoWithPlayerModel:playModel];
    [self configLYPlayer];
}

#pragma mark -- 初始化播放器

- (void)configLYPlayer{
    self.asset = [AVURLAsset assetWithURL:self.videoURL];
    self.playerItem = [AVPlayerItem playerItemWithAsset:_asset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    /**
     AVLayerVideoGravity
     AVLayerVideoGravityResizeAspect:保留宽高比; 适合层边界。
     AVLayerVideoGravityResizeAspectFill:保留宽高比; 填充图层边界。
     AVLayerVideoGravityResize:拉伸以填充图层边界。
     */
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    // 因为之前加了控制层，所以这里要把playerLayer放到self.layer最底下
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    self.backgroundColor = [UIColor blackColor];
//    self.autoPlay = YES;
    
    [self createTimer];
    [self getSystemVolume];
    [self addNotifications];
    [self addGestures];
    [self play];
}

// 手势
- (void)addGestures{
    // 单击显示控制层
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGes.delegate = self;
    [self addGestureRecognizer:tapGes];
}

// 通知
- (void)addNotifications{
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    // 监测设备方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];

    // playerItem播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
}

// 系统音量
- (void)getSystemVolume{
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                    error:&error];
    
    if (!success) { /* handle the error in setCategoryError */ }
}

/**
 *请求在回放期间调用块以报告更改时间。
 intrtval:正常播放期间块的调用间隔，根据播放器当前时间的进度。
 queue:应该将块排队到的串行队列。如果您传递NULL，则将使用主队列（使用dispatch_get_main_queue（）获取）。将并发队列传递给此方法将导致未定义的行为。
 
 符合NSObject协议的对象。只要您希望玩家调用时间观察者，您就必须保留此返回值。
 将此对象传递给-removeTimeObserver：取消时间观察。
 
 该块以指定的时间间隔周期性地调用，根据当前项目的时间线进行解释。
 每当跳转时以及每当播放开始或停止时，也会调用该块。
 如果间隔实时对应于非常短的时间间隔，则玩家可以低于请求频率地调用块。即便如此，玩家也会经常足够地调用该块，以便客户端在其最终用户界面中适当地更新当前时间的指示。
 每次调用-addPeriodicTimeObserverForInterval：queue：usingBlock：都应与对-removeTimeObserver：的相应调用配对。
 释放观察者对象而不调用-removeTimeObserver：将导致未定义的行为。
 
 
 typedef struct
 {
 CMTimeValue    value;
 CMTimeScale    timescale;// 时间被分n份
 CMTimeFlags    flags;
 CMTimeEpoch    epoch;
 } CMTime;
 
 时间(s) = value/timescale
 
 CMTimeMake(100,10) -> 10s
 CMTimeMakeWithSeconds(100,10) -> 100s
 */

// player时间
- (void)createTimer{
    __weak typeof(self) wSelf = self;
    // 请求在播放期间定期调用给定块以报告更改时间。
    self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:NULL usingBlock:^(CMTime time) {
        __strong typeof(wSelf) sSwlf = wSelf;
        AVPlayerItem *currentItem = sSwlf.playerItem;
        // 此属性可以寻求的时间范围的集合。 提供的范围可能是不连续的。
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        // duration持续时间
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [sSwlf.controlView ly_setPlayerCurrentTime:currentTime totalTime:totalTime sliderValue:value];
            
        }
    }];
}


#pragma mark -- 播放、暂停
/**
 * [self.player replaceCurrentItemWithPlayerItem:self.playerItem];这个方法只能用其他item来替换，原item替换无效
 */
- (void)play{
    if (self.state == LYPlayerStateStopped) {// 播放完毕
        // 重新播放
        [self.player seekToTime:CMTimeMake(0, 1)];
    }
    [self.controlView ly_setPlayerPlayButtonStatus:YES];
    self.state = LYPlayerStatePlaying;
    [_player play];
}

- (void)pause{
    [self.controlView ly_setPlayerPlayButtonStatus:NO];
    self.state = LYPlayerStatePause;
    [_player pause];
}

#pragma mark -- 手势
// 显示隐藏控制层
- (void)tapGesture:(UITapGestureRecognizer *)tap{
    [self.controlView ly_playerShowControlView];
}


#pragma mark -- 通知

// 进入后台
- (void)appDidEnterBackground{
    self.enterBackgroud = YES;
    [_player pause];
    self.state = LYPlayerStatePause;
}

// 进入前台
- (void)appDidEnterPlayground{
    self.enterBackgroud = NO;
    [self play];
    self.state = LYPlayerStatePlaying;
}

// 耳机插入、拔出
- (void)audioRouteChange:(NSNotification *)note{
    NSDictionary *info = note.userInfo;
    NSInteger reason = [[info valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            // 耳机拔掉，暂停
            [self pause];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            
            break;
    }
    
    
}

- (void)playerItemDidEnd:(NSNotification *)note{
    self.state = LYPlayerStateStopped;
    // 控制层重置
    [self.controlView resetConfig];
}

/**
 * 屏幕方向改变
 * 手机屏幕改变方向会触发该通知
 typedef NS_ENUM(NSInteger, UIDeviceOrientation) {
     UIDeviceOrientationUnknown,
     UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
     UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
     UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
     UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
     UIDeviceOrientationFaceUp,              // Device oriented flat, face up
     UIDeviceOrientationFaceDown             // Device oriented flat, face down
 } __TVOS_PROHIBITED;
 */
- (void)deviceOrientationChange{
    if (self.isEnterBackgroud) return;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    // 未知、平放朝上、平放朝下、竖直home键朝上 不操作
    if (deviceOrientation == UIDeviceOrientationUnknown || deviceOrientation == UIDeviceOrientationFaceUp || deviceOrientation == UIDeviceOrientationFaceDown || deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }
    
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)deviceOrientation;
    switch (interfaceOrientation) {// 设备方向
        case UIInterfaceOrientationPortrait://屏幕竖直
        {
            [self contrastOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft://屏幕左横
        {
            [self contrastOrientation:UIInterfaceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight://屏幕右横
        {
            [self contrastOrientation:UIInterfaceOrientationLandscapeRight];
        }
            break;
            
        default:
            break;
    }
    
    
}


// 当前屏幕方向与设备方向(转化为UIInterfaceOrientation类型)对比操作
- (void)contrastOrientation:(UIInterfaceOrientation)orientation{
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (currentOrientation == orientation) return;// 一致
    
    if (orientation == UIInterfaceOrientationPortrait) {
        [self removeFromSuperview];
        [_playModel.fatherView addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playModel.fatherView);
        }];
        
    } else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        [self removeFromSuperview];
        [APP_Window addSubview:self];
        
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(APP_Window);
            make.width.equalTo(APP_Window.mas_height);
            make.height.equalTo(APP_Window.mas_width);
        }];
    }
    
    /**
     * iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
     UIViewController+Rotation分类写好方法
     */
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = [self transformRotationAngle];
    }];
}

// 旋转角度
- (CGAffineTransform)transformRotationAngle{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

#pragma mark -- LYPlayerControlViewDelegate

// 返回
- (void)ly_playerBackWithBackMode:(LYPlayerBackMode)backMode{
    if (backMode == LYPlayerBackOutMode) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ly_exitPlayer)]) {
            [self.delegate ly_exitPlayer];
        }
    } else if(backMode == LYPlayerBackShrinkMode){
        [self contrastOrientation:UIInterfaceOrientationPortrait];
    }
}

// 播放按钮
- (void)ly_playerPlay:(BOOL)isPlay{
    if (isPlay == NO) {
        [self pause];
    } else {
        [self play];
    }
}

// 全屏
- (void)ly_playerFullScreen:(BOOL)isFull{
    
    [self contrastOrientation:isFull ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait];
}

// slider滑动事件
- (void)ly_playerSliderValueChange:(UISlider *)slider{
    // 这里只改变控制层下部显示
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        CGFloat value = slider.value;
        CGFloat totalTime = (CGFloat)self.player.currentItem.duration.value / self.player.currentItem.duration.timescale;
        CMTime cmt = CMTimeMakeWithSeconds(value * totalTime, self.player.currentItem.duration.timescale);
        [self.controlView ly_setPlayerCurrentTime:CMTimeGetSeconds(cmt) totalTime:totalTime sliderValue:-1];
    } else {
        slider.value = 0;
    }
}

// slider滑动结束事件
- (void)ly_playerSliderTouchEnded:(UISlider *)slider{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        CGFloat value = slider.value;
        CGFloat totalTime = (CGFloat)self.player.currentItem.duration.value / self.player.currentItem.duration.timescale;
        CMTime cmt = CMTimeMakeWithSeconds(value * totalTime, self.player.currentItem.duration.timescale);
        [self.player pause];
        __weak typeof(self) wSelf = self;
        // 这个寻找更精确
        [self.player seekToTime:cmt toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
            __strong typeof(wSelf) sSwlf = wSelf;
            [sSwlf.player play];
            // 保证播放按钮一致
            [sSwlf.controlView ly_setPlayerPlayButtonStatus:YES];
        }];

    } else {
        
    }
}



@end
