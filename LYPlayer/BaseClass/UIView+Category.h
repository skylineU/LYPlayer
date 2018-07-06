//
//  UIView+Category.h
//  game
//
//  Created by 马凌云 on 2018/3/8.
//  Copyright © 2018年 YD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)

/**
*  alertController提示框（不能再viewdidload中使用）
*
*  @param controller   controller
*  @param title   title
*  @param message   message
*  @param sureTitle   sureTitle
*  @param cancelTitle   cancelTitle
*  @param sureHandler   sureHandler
*  @param cancelHandler   cancelHandler
*
*/
- (void)alertController:(UIViewController * _Nonnull)controller title:(NSString * _Nullable)title message:(NSString * _Nullable)message sureTitle:(NSString * _Nullable)sureTitle cancelTitle:(NSString * _Nullable)cancelTitle sureHandler:(void (^_Nullable)(UIAlertAction * _Nonnull action))sureHandler cancelHandler:(void (^_Nullable)(UIAlertAction * _Nonnull action))cancelHandler;

/*
 View上寻找当前控制器
 */
- (UIViewController * _Nullable)getCurrentViewController;

@end
