//
//  DCSideMenuViewController.h
//  DCSlideMenu
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DCSideMenuProtocol.h"


@interface DCSideMenuViewController : UIViewController

@property (nonatomic, assign, readonly) NSUInteger  selectedIndex;
@property (nonatomic, assign, readonly) BOOL        isOpen;

@property (nonatomic, strong, readonly) UIViewController *sideMenuViewController;
@property (nonatomic, strong, readonly) UIViewController *selectedViewController;

@property (nonatomic, weak) NSObject <DCSideMenuDataSource> *dataSource;
@property (nonatomic, weak) NSObject <DCSideMenuDelegate>   *delegate;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)setSideMenuViewController:(UIViewController *)sideMenuViewController animated:(BOOL)animated;

@end
