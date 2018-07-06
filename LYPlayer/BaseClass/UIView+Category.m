//
//  UIView+Category.m
//  game
//
//  Created by 马凌云 on 2018/3/8.
//  Copyright © 2018年 YD. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

- (void)alertController:(UIViewController * _Nonnull)controller title:(NSString * _Nullable)title message:(NSString * _Nullable)message sureTitle:(NSString * _Nullable)sureTitle cancelTitle:(NSString * _Nullable)cancelTitle sureHandler:(void (^_Nullable)(UIAlertAction * _Nonnull action))sureHandler cancelHandler:(void (^_Nullable)(UIAlertAction * _Nonnull action))cancelHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    if (sureTitle && sureTitle.length > 0) {
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureTitle style:(UIAlertActionStyleDefault) handler:sureHandler];
        [alert addAction:sureAction];
    }
    
    if (cancelTitle && cancelTitle.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:(UIAlertActionStyleDefault) handler:cancelHandler];
        [alert addAction:cancelAction];
    }
    
    [controller presentViewController:alert animated:YES completion:nil];
    
}

- (UIViewController * _Nullable)getCurrentViewController{
    
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
        
    } while (responder != nil);

    return nil;
}

@end
