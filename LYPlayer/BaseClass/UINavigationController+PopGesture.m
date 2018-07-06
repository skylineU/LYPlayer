//
//  UINavigationController+PopGesture.m
//  LYPlayer
//
//  Created by yun on 2018/5/10.
//  Copyright © 2018年 yun. All rights reserved.
//

#import "UINavigationController+PopGesture.h"
#import <objc/runtime.h>

#define APP_WINDOW                  [UIApplication sharedApplication].delegate.window
#define SCREEN_WIDTH                [UIScreen mainScreen].bounds.size.width
#define SCREEN_BOUNDS               [UIScreen mainScreen].bounds
#define MASK_COLOR(x)               [[UIColor blackColor] colorWithAlphaComponent:0.5-x]

static CGFloat const animationTimes  = 0.25;

#pragma mark -- pop返回时背景view

@interface LYScreenShotView : UIView
// 截图图片
@property (nonatomic,strong) UIImageView *imageView;
// 遮盖层
@property (nonatomic,strong) UIView *maskView;

@end

@implementation LYScreenShotView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self addSubview:_imageView];
        
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:_maskView];
    }
    return self;
}


@end

#pragma mark -- UIViewController一些属性绑定

static const void *ly_navigationBarHiddenKey = &ly_navigationBarHiddenKey;
static const void *ly_popDisabledKey = &ly_popDisabledKey;
static const void *ly_recognizeSimultaneouslyEnableKey = &ly_recognizeSimultaneouslyEnableKey;

@implementation UIViewController (PopGesture)
// 关联绑定
- (void)setLy_navigationBarHidden:(BOOL)ly_navigationBarHidden{
    //ly_navigationBarHidden转成NSNumber类型
    objc_setAssociatedObject(self, ly_navigationBarHiddenKey, @(ly_navigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ly_navigationBarHidden{
    
   return [objc_getAssociatedObject(self, ly_navigationBarHiddenKey) boolValue];
}

- (void)setLy_popDisabled:(BOOL)ly_popDisabled{
    objc_setAssociatedObject(self, ly_popDisabledKey, @(ly_popDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ly_popDisabled{
    return [objc_getAssociatedObject(self, ly_popDisabledKey) boolValue];
}

- (void)setLy_recognizeSimultaneouslyEnable:(BOOL)ly_recognizeSimultaneouslyEnable{
    objc_setAssociatedObject(self, ly_recognizeSimultaneouslyEnableKey, @(ly_recognizeSimultaneouslyEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ly_recognizeSimultaneouslyEnable{
    return [objc_getAssociatedObject(self, ly_recognizeSimultaneouslyEnableKey) boolValue];
}

@end

#pragma mark -- UIViewController的一个block回调

// 定义一个block
typedef void(^LYVCWillAppearInjectBlock) (UIViewController *vc,BOOL animated);

static const void *ly_willAppearInjectBlockKey = &ly_willAppearInjectBlockKey;

@interface UIViewController (PopGesturePrivate)

@property (nonatomic,copy) LYVCWillAppearInjectBlock ly_willAppearInjectBlock;

@end

@implementation UIViewController (PopGesturePrivate)

+ (void)load{
    
    Class aClass = [self class];
    SEL originSel = @selector(viewWillAppear:);
    SEL swizzledSel = @selector(ly_viewWillAppear:);
    
    Method originM = class_getInstanceMethod(aClass, originSel);
    Method swizzledM = class_getInstanceMethod(aClass, swizzledSel);
    
    BOOL success = class_addMethod(aClass, originSel, method_getImplementation(swizzledM), method_getTypeEncoding(swizzledM));
    if (success) {
        class_replaceMethod(aClass, swizzledSel, method_getImplementation(originM), method_getTypeEncoding(originM));
    } else {
        method_exchangeImplementations(originM, swizzledM);
    }
}

- (void)ly_viewWillAppear:(BOOL)animated{
    // 方法已交换
    [self ly_viewWillAppear:animated];
    
    if (self.ly_willAppearInjectBlock) {
        self.ly_willAppearInjectBlock(self, animated);
    }
}


- (void)setLy_willAppearInjectBlock:(LYVCWillAppearInjectBlock)ly_willAppearInjectBlock{
    objc_setAssociatedObject(self, ly_willAppearInjectBlockKey, ly_willAppearInjectBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (LYVCWillAppearInjectBlock)ly_willAppearInjectBlock{
    return objc_getAssociatedObject(self, ly_willAppearInjectBlockKey);
}


@end



static const void *popGestureStyleKey = &popGestureStyleKey;

@implementation UINavigationController (PopGesture)


+ (void)load{
    Class aClass = [self class];
    
    // c数组
    SEL sel[] = {
        @selector(viewDidLoad),
        @selector(pushViewController:animated:),
        @selector(popViewControllerAnimated:),
        @selector(popToViewController:animated:),
        @selector(popToRootViewControllerAnimated:)
        
    };
    
    for (int index = 0; index < sizeof(sel)/sizeof(SEL); index++) {
        SEL originSel = sel[index];
        SEL swizzledSel = NSSelectorFromString([@"ly_" stringByAppendingString:NSStringFromSelector(originSel)]);
        Method originM = class_getInstanceMethod(aClass, originSel);
        Method swizzledM = class_getInstanceMethod(aClass, swizzledSel);
        BOOL success = class_addMethod(aClass, originSel, method_getImplementation(swizzledM), method_getTypeEncoding(swizzledM));
        if (success) {
            class_replaceMethod(aClass, swizzledSel, method_getImplementation(originM), method_getTypeEncoding(originM));
        } else {
            method_exchangeImplementations(originM, swizzledM);
        }
    }
}

#pragma mark -- 各种方法push、pop方法

- (void)ly_viewDidLoad{
    [self ly_viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = NO;// 关闭pop手势
    self.ly_navigationBarAppearanceEnabled = YES;//能否设置navigationBar
    self.showViewOffsetScale = 1/3.f;
    self.showViewOffset = self.showViewOffsetScale * SCREEN_WIDTH;
    self.screenShotView.hidden = YES;
    // 默认渐变
    self.popGestureStyle = LYPopGestureGradientStyle;
    // 自定义返回手势
    UIPanGestureRecognizer *popRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(popRecognizer:)];
    popRecognizer.delegate = self;
    [self.view addGestureRecognizer:popRecognizer];
}

- (void)ly_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count > 0) {
        // 截屏
        [self screenShot];
    }
    
    // 设置navigationBar
    [self ly_setupNavigationBarAppearanceIfNeeded:viewController];
    
    // 当navigationController子控制器数组中没有viewController，push到新的viewController
    if (![self.viewControllers containsObject:viewController]) {
        [self ly_pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)ly_popViewControllerAnimated:(BOOL)animated{
    [self.screenShotsArray removeLastObject];
    return [self ly_popViewControllerAnimated:animated];
}

// 从堆栈弹出的视图控制器的数组。
- (NSArray<UIViewController *> *)ly_popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSArray *vcs = [self ly_popToViewController:viewController animated:animated];
    if (self.screenShotsArray.count >= vcs.count) {// 数组安全操作，防止数组越界
        // 未使用变量
#pragma clang diagnostic push
#pragma clang diagnostic ignored   "-Wunused-variable"
        for (UIViewController *vc in vcs) {
            [self.screenShotsArray removeLastObject];
        }
#pragma clang diagnostic pop
        
    }
    return vcs;
}

- (NSArray <UIViewController *> *)ly_popToRootViewControllerAnimated:(BOOL)animated{
    [self.screenShotsArray removeAllObjects];
    return [self ly_popToRootViewControllerAnimated:animated];
}


#pragma mark -- method
// 设置navigationBar 隐藏显示效果
- (void)ly_setupNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController{
    if (!self.ly_navigationBarAppearanceEnabled) {
        return;
    }
    
    __weak typeof(self) wSelf = self;
    LYVCWillAppearInjectBlock block = ^(UIViewController *vc,BOOL animated){
        __strong typeof(wSelf) sSelf = wSelf;
        [sSelf setNavigationBarHidden:vc.ly_navigationBarHidden animated:animated];
    };
    // 将要出现的界面执行block
    appearingViewController.ly_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    // 将要消失的界面是否执行block视情况而定：disappearingViewController有且disappearingViewController的ly_willAppearInjectBlock == nil
    if (disappearingViewController && !disappearingViewController.ly_willAppearInjectBlock) {
        disappearingViewController.ly_willAppearInjectBlock = block;
    }
}

// 截屏
- (void)screenShot{
    
    if (self.childViewControllers.count == self.screenShotsArray.count + 1) {
        /*
         UIKIT_EXTERN void     UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
         用指定的选项创建一个基于位图的图形上下文。
         opaque:yes,位图不透明
         scale：适用于位图的比例因子。 如果您指定的值为0.0，则缩放系数将设置为设备主屏幕的缩放系数。
         */
        UIGraphicsBeginImageContextWithOptions(APP_WINDOW.bounds.size, YES, 0);
        /*
         - (void)renderInContext:(CGContextRef)ctx;
         将图层及其子图层渲染到指定的上下文中。
         ctx:用于渲染图层的图形上下文。
         
         UIKIT_EXTERN CGContextRef __nullable UIGraphicsGetCurrentContext(void) CF_RETURNS_NOT_RETAINED;
         返回当前的图形上下文。
         */
        [APP_WINDOW.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.screenShotsArray addObject:image];
    }
}

#pragma mark -- 手势
- (void)popRecognizer:(UIPanGestureRecognizer *)ges{
    if (self.viewControllers.count <= 1) return;// navi只有一个子控制器停止拖拽
    // 触点为原点，平移后触点相对于原点的坐标位置。
    CGFloat tx = [ges translationInView:ges.view].x;
    CGFloat widthScale = 0.0;
    if (ges.state == UIGestureRecognizerStateBegan) {
        widthScale = 0;
        self.screenShotView.hidden = NO;
        self.screenShotView.imageView.image = [self.screenShotsArray lastObject];
        /*
         CGAffineTransform CGAffineTransformTranslate(CGAffineTransform t, CGFloat tx, CGFloat ty);
         返回通过转换现有仿射变换构造的仿射变换矩阵。
         */
        self.screenShotView.imageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset, 0);
        self.screenShotView.maskView.backgroundColor = MASK_COLOR(0);
    } else if(ges.state == UIGestureRecognizerStateChanged){
        if (tx < 0) return;// 左滑无效
        
        widthScale = tx/SCREEN_WIDTH;
        self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,tx, 0);
        self.screenShotView.imageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset + tx * self.showViewOffsetScale, 0);
        self.screenShotView.maskView.backgroundColor = MASK_COLOR(widthScale/2.f);
    } else if (ges.state == UIGestureRecognizerStateEnded){
        CGPoint velocity = [ges velocityInView:ges.view];// 平移速度
        BOOL undo = velocity.x > 0;
        if (tx >= SCREEN_WIDTH/3.f && undo) {// 大于三分之一屏幕宽且平移速度大于0(x方向) pop
            [UIView animateWithDuration:animationTimes animations:^{
                
                self.screenShotView.imageView.transform = undo ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset, 0);
                self.view.transform = undo ? CGAffineTransformTranslate(CGAffineTransformIdentity, SCREEN_WIDTH, 0) : CGAffineTransformIdentity;
                self.screenShotView.maskView.backgroundColor = [UIColor clearColor];
                
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                self.screenShotView.hidden = YES;
                self.view.transform = CGAffineTransformIdentity;
                self.screenShotView.imageView.transform = CGAffineTransformIdentity;
                
            }];
        } else {// 回弹
            [UIView animateWithDuration:animationTimes animations:^{
                
                self.view.transform = CGAffineTransformIdentity;
                self.screenShotView.imageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset, 0);
                self.screenShotView.maskView.backgroundColor = MASK_COLOR(widthScale/2.f);
                
            } completion:^(BOOL finished) {
                self.screenShotView.imageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

#pragma mark -- 手势代理
// 接受手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (self.visibleViewController.ly_popDisabled) return NO;// 关闭当前vc的pop功能，默认NO
    if (self.viewControllers.count <= 1) return NO;// 子控制器为1时
    // 手势触发条件：UIPanGestureRecognizer、手指x在屏幕宽度区间
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.x < SCREEN_WIDTH) {
            return YES;
        }
    }
    return NO;
}

// 手势共存
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (self.visibleViewController.ly_recognizeSimultaneouslyEnable) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScreenEdgePanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")] ) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- 关联

- (void)setPopGestureStyle:(LYPopGestureStyle)popGestureStyle{
    objc_setAssociatedObject(self, popGestureStyleKey, @(popGestureStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (popGestureStyle == LYPopGestureShadowStyle) {
        
    }
}

- (LYPopGestureStyle)popGestureStyle{
    return [objc_getAssociatedObject(self, popGestureStyleKey) integerValue];
}

static const void *ly_navigationBarAppearanceEnabledKey = &ly_navigationBarAppearanceEnabledKey;
- (void)setLy_navigationBarAppearanceEnabled:(BOOL)ly_navigationBarAppearanceEnabled{
    objc_setAssociatedObject(self, ly_navigationBarAppearanceEnabledKey, @(ly_navigationBarAppearanceEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ly_navigationBarAppearanceEnabled{
    return [objc_getAssociatedObject(self, ly_navigationBarAppearanceEnabledKey) boolValue];
}

// showView移动比例
static const void *showViewOffsetScaleKey = &showViewOffsetScaleKey;
- (void)setShowViewOffsetScale:(CGFloat)showViewOffsetScale{
    objc_setAssociatedObject(self, showViewOffsetScaleKey, @(showViewOffsetScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)showViewOffsetScale{
    return [objc_getAssociatedObject(self, showViewOffsetScaleKey) floatValue];
}

// showView移动
static const void *showViewOffsetKey = &showViewOffsetKey;
- (void)setShowViewOffset:(CGFloat)showViewOffset{
    objc_setAssociatedObject(self, showViewOffsetKey, @(showViewOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)showViewOffset{
    return [objc_getAssociatedObject(self, showViewOffsetKey) floatValue];
}

// pop时的背景
static const void *screenShotViewKey = &screenShotViewKey;
- (LYScreenShotView *)screenShotView{
    LYScreenShotView *shotView = objc_getAssociatedObject(self, screenShotViewKey);
    if (!shotView) {
        shotView = [LYScreenShotView new];
        shotView.hidden = YES;
        // 最底层
        [APP_WINDOW insertSubview:shotView atIndex:0];
        objc_setAssociatedObject(self, screenShotViewKey, shotView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return shotView;
}

// 截图数组
static const void *screenShotsArrayKey = &screenShotsArrayKey;
- (NSMutableArray<UIImage *> *)screenShotsArray{
    NSMutableArray *screenShots = objc_getAssociatedObject(self, screenShotsArrayKey);
    if (!screenShots) {
        screenShots = [NSMutableArray new];
        objc_setAssociatedObject(self, screenShotsArrayKey, screenShots, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return screenShots;
}


@end
