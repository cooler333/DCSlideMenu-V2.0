//
//  DCAppDelegate.m
//  DCSlideMenu
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import "DCAppDelegate.h"

#import "DCSideMenuViewControllerSubclass.h"


@implementation DCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    
// Create view pragmaticaly/With Nib or delete it if you are using UIStoryboard
/*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 
    // Add the controller's current view as a subview of the window
    UIViewController *vc = [[DCSideMenuViewControllerSubclass alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
*/
    return YES;
}

@end
