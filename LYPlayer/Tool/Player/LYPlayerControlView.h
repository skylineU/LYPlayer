//
//  LYPlayerControlView.h
//  LYPlayer
//
//  Created by yun on 2018/7/3.
//  Copyright © 2018年 yun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYPlayerModel.h"

typedef NS_ENUM(NSInteger,LYPlayerBackMode) {
    LYPlayerBackOutMode,    // 退出播放VC
    LYPlayerBackShrinkMode  // 退出全屏模式，并未退出VC
};

@protocol LYPlayerControlViewDelegate <NSObject>

// 返回
- (void)ly_playerBackWithBackMode:(LYPlayerBackMode)backMode;
// 播放按钮
- (void)ly_playerPlay:(BOOL)isPlay;
// 全屏
- (void)ly_playerFullScreen:(BOOL)isFull;
// slider滑动事件
- (void)ly_playerSliderValueChange:(UISlider *)slider;
// slider滑动结束事件
- (void)ly_playerSliderTouchEnded:(UISlider *)slider;

@optional



@end

@interface LYPlayerControlView : UIView

@property(nonatomic,weak) id<LYPlayerControlViewDelegate> delegate;

/**
 * 设置播放器当前时间，总时长，slider值
 */
- (void)ly_setPlayerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)sliderValue;

/**
 * 设置playerModel的信息
 */
- (void)ly_setInfoWithPlayerModel:(LYPlayerModel *)playerModel;

/**
 * 设置播放按钮的状态
 */
- (void)ly_setPlayerPlayButtonStatus:(BOOL)isPlay;

/**
 * 显示控制层
 */
- (void)ly_playerShowControlView;


@end
