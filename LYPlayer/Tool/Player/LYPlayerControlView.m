//
//  LYPlayerControlView.m
//  LYPlayer
//
//  Created by yun on 2018/7/3.
//  Copyright © 2018年 yun. All rights reserved.
//

#import "LYPlayerControlView.h"
#import "LYPlayerConfiguration.h"
#import "Masonry.h"

@interface LYPlayerControlView ()


// 背景图，上部、下部背景
@property(nonatomic,strong) UIImageView *backgroudImgV;
@property(nonatomic,strong) UIImageView *topImgV;
@property(nonatomic,strong) UIImageView *bottomImgV;

@property(nonatomic,strong) UIButton *backButton;// 返回按钮
@property(nonatomic,strong) UILabel *titleLabel;// 视频标题
@property(nonatomic,strong) UIButton *playPauseButton;// 播放暂停按钮
@property(nonatomic,strong) UILabel *currentTimeLabel;
@property(nonatomic,strong) UILabel *totalTimeLabel;
@property(nonatomic,strong) UISlider *slider;
@property(nonatomic,strong) UIButton *fullScreenButton;// 全屏按钮

/// 状态
/**
 * 全屏和竖屏控制层隐藏有区别，全屏全隐藏，竖屏显示返回按钮
 */
@property(nonatomic,assign,getter=isShow) BOOL show;// 是否显示控制层
@property(nonatomic,assign,getter=isFullScreen) BOOL fullScreen;// 是否全屏




@end


@implementation LYPlayerControlView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSubviews];
    }
    return self;
}


- (void)initSubviews{
    // 根据视频显示占位图
    self.backgroudImgV = [[UIImageView alloc] init];
    self.backgroudImgV.userInteractionEnabled = YES;
    [self addSubview:self.backgroudImgV];
    [self.backgroudImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.topImgV = [[UIImageView alloc] initWithImage:LYPlayerImage(@"LYPlayer_top_shadow")];
    self.topImgV.userInteractionEnabled = YES;
    [self addSubview:self.topImgV];
    [self.topImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    self.bottomImgV = [[UIImageView alloc] initWithImage:LYPlayerImage(@"LYPlayer_bottom_shadow")];
    self.bottomImgV.userInteractionEnabled = YES;
    [self addSubview:self.bottomImgV];
    [self.bottomImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    // 各种小控件
    // 上部
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:LYPlayerImage(@"LYPlayer_back_full") forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topImgV addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topImgV);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.topImgV addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right).offset(5);
        make.right.mas_equalTo(-10);
    }];
    
    // 下部
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playPauseButton setImage:LYPlayerImage(@"LYPlayer_play") forState:UIControlStateNormal];
    [self.playPauseButton setImage:LYPlayerImage(@"LYPlayer_pause") forState:UIControlStateSelected];
    [self.playPauseButton addTarget:self action:@selector(playPauseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomImgV addSubview:self.playPauseButton];
    [self.playPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomImgV);
        make.left.mas_equalTo(5);
        make.width.height.mas_equalTo(30);
    }];
    
    self.currentTimeLabel = [[UILabel alloc] init];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:12];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomImgV addSubview:self.currentTimeLabel];
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playPauseButton);
        make.left.equalTo(self.playPauseButton.mas_right);
        make.width.mas_equalTo(40);
    }];
    
    self.fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreenButton setImage:LYPlayerImage(@"LYPlayer_fullscreen") forState:UIControlStateNormal];
    [self.fullScreenButton setImage:LYPlayerImage(@"LYPlayer_shrinkscreen") forState:UIControlStateSelected];
    [self.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomImgV addSubview:self.fullScreenButton];
    [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playPauseButton);
        make.right.mas_equalTo(-5);
        make.width.height.mas_equalTo(30);
    }];
    
    self.totalTimeLabel = [[UILabel alloc] init];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:12];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomImgV addSubview:self.totalTimeLabel];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playPauseButton);
        make.right.equalTo(self.fullScreenButton.mas_left);
        make.width.mas_equalTo(40);
    }];
    
    self.slider = [[UISlider alloc] init];
    [self.slider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider setThumbImage:LYPlayerImage(@"LYPlayer_slider") forState:UIControlStateNormal];
    self.slider.minimumTrackTintColor = [UIColor whiteColor];
    self.slider.maximumTrackTintColor = RGBA(125, 125, 125, 0.5);
    [self.bottomImgV addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playPauseButton);
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(2);
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(-2);
        make.height.mas_equalTo(30);
    }];
    
    [self resetConfig];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {// 竖屏
        [self setOrientationPortrait];
    } else {// 横屏
        [self setOrientationLandscape];
    }
}

// 竖屏约束
- (void)setOrientationPortrait{
    self.fullScreenButton.selected = NO;
    self.fullScreen = NO;
    [self showAndAutoHideControlView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topImgV);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
}

// 横屏约束
- (void)setOrientationLandscape{
    self.fullScreenButton.selected = YES;
    self.fullScreen = YES;
    [self showAndAutoHideControlView];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}



// 重置设置
- (void)resetConfig{
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"00:00";
    self.slider.value = 0;
    
    /// 状态赋值

}




#pragma mark -- action
// 返回
- (void)backButtonClick{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ly_playerBackWithBackMode:)]) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationPortrait) {// 竖屏
            [self.delegate ly_playerBackWithBackMode:LYPlayerBackOutMode];
        } else {
            [self.delegate ly_playerBackWithBackMode:LYPlayerBackShrinkMode];
        }
    }
    
}
// 播放暂停
- (void)playPauseButtonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ly_playerPlay:)]) {
        [self.delegate ly_playerPlay:sender.selected];
    }
}
// 全屏、缩放
- (void)fullScreenButtonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ly_playerFullScreen:)]) {
        [self.delegate ly_playerFullScreen:sender.selected];
    }
    
}
// 滑动中
- (void)sliderValueChange:(UISlider *)sender{
    // 需要显示控制层
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self showControlView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ly_playerSliderValueChange:)]) {
        [self.delegate ly_playerSliderValueChange:sender];
    }
}
// 滑动停止
- (void)sliderTouchEnded:(UISlider *)sender{
    [self autoHideControlView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ly_playerSliderTouchEnded:)]) {
        [self.delegate ly_playerSliderTouchEnded:sender];
    }
}


#pragma mark -- private

// 先显示再自动隐藏
- (void)showAndAutoHideControlView{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self showControlView];
    } completion:^(BOOL finished) {
        [self autoHideControlView];
    }];
}

// 自动隐藏控制层（5s）
- (void)autoHideControlView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:5];
}

// 显示控制层
- (void)showControlView{
    self.show = YES;
    
    self.hidden = NO;
    self.titleLabel.hidden = NO;
    self.backButton.hidden = NO;
    self.bottomImgV.hidden = NO;
    if (self.isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

// 隐藏控制层
- (void)hideControlView{
    self.show = NO;
    if (self.isFullScreen) {
        self.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    } else {
        self.hidden = NO;
//        self.topImgV.alpha = 0.5;
        self.titleLabel.hidden = YES;
        self.backButton.hidden = NO;
        self.bottomImgV.hidden = YES;
        
    }
}


#pragma mark -- public

- (void)ly_setPlayerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)sliderValue{
    NSInteger curSecs = currentTime%60;
    NSInteger curmins = currentTime/60;
    
    NSInteger totSecs = totalTime%60;
    NSInteger totmins = totalTime/60;
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)curmins,(long)curSecs];
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)totmins,(long)totSecs];
    if (sliderValue >= 0) {// 负数是为了滑动slider时做的处理
        self.slider.value = sliderValue;
    }
}

- (void)ly_setInfoWithPlayerModel:(LYPlayerModel *)playerModel{
    self.titleLabel.text = playerModel.title;
}

- (void)ly_setPlayerPlayButtonStatus:(BOOL)isPlay{
    self.playPauseButton.selected = isPlay;
}

- (void)ly_playerShowControlView{
    if (self.show) {
        [self hideControlView];
    } else {
        [self showAndAutoHideControlView];
    }
    
}






@end
