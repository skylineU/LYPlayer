//
//  MainTabBarViewController.m
//  LYPlayer
//
//  Created by yun on 2018/5/14.
//  Copyright © 2018年 yun. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewControllers = [self childControllers];
    
}

- (NSArray <UINavigationController *> *)childControllers{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TabbarItems" ofType:@"plist"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *naviArray = [NSMutableArray new];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UINavigationController *navi = [self setTabbarItemWithController:obj[@"controller"] title:obj[@"title"] image:obj[@"image"] selectedImage:obj[@"selectedImage"]];
        [naviArray addObject:navi];
    }];
    
    return naviArray;
}


- (UINavigationController *)setTabbarItemWithController:(NSString *)controller title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage{
    UINavigationController *na1 = [[UINavigationController alloc] initWithRootViewController:[NSClassFromString(controller) new]];
    na1.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:image] selectedImage:[UIImage imageNamed:selectedImage]];
    return na1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
