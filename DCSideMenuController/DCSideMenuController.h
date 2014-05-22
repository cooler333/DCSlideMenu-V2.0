//
//  DCSideMenuController.h
//  DCSlideMenu
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol DCSideMenuDataSource;

typedef NS_ENUM(NSUInteger, DCSideMenuOrientation) {
    DCSideMenuOrientationAll,
    DCSideMenuOrientationPortrait,
    DCSideMenuOrientationLandscape
};


@interface DCSideMenuController : UIViewController

//
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;
@property (nonatomic, weak) id <DCSideMenuDataSource> dataSource;
//

@property (nonatomic, strong, readonly) UIViewController *leftMenuController;

@property (nonatomic, assign) CGFloat phonePortraitMenuWidth;
@property (nonatomic, assign) CGFloat phoneLandscapeMenuWidth;

@property (nonatomic, assign) CGFloat padPortraitMenuWidth;
@property (nonatomic, assign) CGFloat padLandscapeMenuWidth;

@property (nonatomic, assign) Boolean shouldBounce;

@property (nonatomic, assign, readonly) Boolean isOpen;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(Boolean)animated;
- (void)setLeftMenuController:(UIViewController *)leftMenuController animated:(Boolean)animated;

@end


@protocol DCSideMenuDataSource<NSObject>

@required

- (UIViewController *)viewControllerForLeftMenuOrientation:(DCSideMenuOrientation)orientation;
- (UIViewController *)viewControllerForContentAtIndex:(NSUInteger)index;

@end