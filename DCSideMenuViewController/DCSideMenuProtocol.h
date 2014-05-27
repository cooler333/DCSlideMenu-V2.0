//
//  DCSideMenuProtocol.h
//  DCSlideMenu
//
//  Created by Admin on 26.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DCSideMenuViewController;

@protocol DCSideMenuDataSource <NSObject>

@required
- (UIViewController *)viewControllerForItemAtIndex:(NSUInteger)idx;    // Default: nil

@optional
- (CGFloat)menuWidthForOrientation:(UIInterfaceOrientation)orientation;     // Default: 230 points;
- (UIImage *)imageForMenuBarButtonItem;                                     // if nil: title.text = @"Menu" else: image;
- (BOOL)shouldBounce;                                                    // Default: YES;
- (NSUInteger)shouldStartAtIndex;

@end

@protocol DCSideMenuDelegate <NSObject>

@optional
- (BOOL)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController shouldSelectItemAtIndex:(NSUInteger)idx; // Default: YES;

- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController willSelectItemAtIndex:(NSUInteger)idx;
- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController willDeselectItemAtIndex:(NSUInteger)idx;

- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController didSelectItemAtIndex:(NSUInteger)idx;
- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController didDeselectItemAtIndex:(NSUInteger)idx;

@end
