//
//  UINavigationController+PopGesture.h
//  LYPlayer
//
//  Created by yun on 2018/5/10.
//  Copyright © 2018年 yun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PopGesture)
// 隐藏NavigationBar:默认NO
@property (nonatomic,assign) BOOL ly_navigationBarHidden;
// 关闭某个控制器的pop手势:默认NO
@property (nonatomic,assign) BOOL ly_popDisabled;
// 自定义的滑动返回手势是否与其他手势共存，一般使用默认值(默认返回NO：不与任何手势共存)
@property (nonatomic,assign) BOOL ly_recognizeSimultaneouslyEnable;

@end

typedef NS_ENUM(NSInteger,LYPopGestureStyle) {
    LYPopGestureGradientStyle,
    LYPopGestureShadowStyle
};

@interface UINavigationController (PopGesture)<UIGestureRecognizerDelegate>
// 默认LYPopGestureStyle
@property (nonatomic,assign) LYPopGestureStyle popGestureStyle;

@end
