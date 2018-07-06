//
//  LYPlayerModel.h
//  LYPlayer
//
//  Created by yun on 2018/5/14.
//  Copyright © 2018年 yun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LYPlayerModel : NSObject

// 视频标题
@property(nonatomic,copy) NSString *title;
// 视频url
@property(nonatomic,strong) NSURL *videoURL;
// 父视图 LYPlayerView和fatherView会相互引用，故用weak修饰
@property(nonatomic,weak) UIView *fatherView;




@end
