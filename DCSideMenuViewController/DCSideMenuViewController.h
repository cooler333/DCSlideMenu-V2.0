//
//  DCSideMenuViewController.h
//  DCSlideMenu
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol DCSideMenuDataSource;
@protocol DCSideMenuDelegate;


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


@protocol DCSideMenuDataSource <NSObject>

@required
- (UIViewController *)viewControllerForContentAtIndex:(NSUInteger)index;    // Default: nil

@optional
- (CGFloat)menuWidthForOrientation:(UIInterfaceOrientation)orientation;     // Default: 230 points;
- (UIImage *)imageForMenuBarButtonItem;                                     // if nil: title.text = @"Menu" else: image;
- (Boolean)shouldBounce;                                                    // Default: YES;


@end

@protocol DCSideMenuDelegate <NSObject>

@optional
- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController willSelectItemAtIndex:(NSUInteger)idx;
- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController didSelectItemAtIndex:(NSUInteger)idx;

@end
