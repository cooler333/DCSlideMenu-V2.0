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

//
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;
@property (nonatomic, assign, readonly) Boolean isOpen;

@property (nonatomic, weak) id <DCSideMenuDataSource> dataSource;
@property (nonatomic, weak) id <DCSideMenuDelegate> delegate;
//

@property (nonatomic, strong, readonly) UIViewController *sideMenuViewController;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(Boolean)animated;
- (void)setSideMenuViewController:(UIViewController *)sideMenuViewController animated:(Boolean)animated;

@end
