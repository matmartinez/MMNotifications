//
//  AppDelegate.m
//  MMNotificationsDemo
//
//  Created by Matías Martínez on 1/30/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:[[DemoViewController alloc] init]];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = rootViewController;
    
    self.window = window;
    
    [window makeKeyAndVisible];
    
    return YES;
}

@end
