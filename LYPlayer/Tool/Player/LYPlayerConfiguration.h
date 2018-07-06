//
//  LYPlayerConfiguration.h
//  LYPlayer
//
//  Created by yun on 2018/5/14.
//  Copyright © 2018年 yun. All rights reserved.
//

#ifndef LYPlayerConfiguration_h
#define LYPlayerConfiguration_h

// 图片路径
#define LYPlayerSrcName(file) [@"LYPlayer.bundle" stringByAppendingPathComponent:file]
// 设置图片
#define LYPlayerImage(file) [UIImage imageNamed:LYPlayerSrcName(file)]

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]

#define APP_Window [UIApplication sharedApplication].delegate.window


#endif /* LYPlayerConfiguration_h */
