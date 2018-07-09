//
//  LYPlayerView.h
//  LYPlayer
//
//  Created by yun on 2018/5/14.
//  Copyright © 2018年 yun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYPlayerModel.h"

typedef NS_ENUM(NSInteger,LYPlayerMode) {
    LYPlayerCommonMode,// 普通
    LYPlayerSingletonMode // 单利
};

typedef NS_ENUM(NSInteger,LYPlayerState) {
    LYPlayerStateFail,      // 播放失败
    LYPlayerStateBuffering, // 缓冲中
    LYPlayerStatePlaying,   // 播放中
    LYPlayerStatePause,     // 暂停播放
    LYPlayerStateStopped    // 停止播放
};

@protocol LYPlayerViewDelegate <NSObject>

@optional
// 退出播放器
- (void)ly_exitPlayer;

@end

@interface LYPlayerView : UIView

@property(nonatomic,weak) id<LYPlayerViewDelegate> delegate;


- (void)defaultControlViewWithPlayerModel:(LYPlayerModel *)playerModel;

@end
