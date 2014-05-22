//
//  DCSideMenuViewController.m
//  DCSlideMenu(TabBar)
//
//  Created by Admin on 21.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import "DCSideMenuViewControllerSubclass.h"
#import "DCLeftSideMenuTableViewController.h"
#import "DCLeftItemSideViewController.h"


@interface DCSideMenuViewControllerSubclass () <DCSideMenuDataSource>

@end


@implementation DCSideMenuViewControllerSubclass

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.phonePortraitMenuWidth = 100.0f;
    self.phoneLandscapeMenuWidth = 400.0f;
    
    self.padPortraitMenuWidth = 400.0f;
    self.padLandscapeMenuWidth = 500.0f;
    
    self.shouldBounce = YES;
    
// !!!: Important
    self.dataSource = self;
}

#pragma mark - DCSideMenuDataSource

- (UIViewController *)viewControllerForLeftMenuOrientation:(DCSideMenuOrientation)orientation {
    switch (orientation) {
        case DCSideMenuOrientationAll: { // Default
// Use in all orientations
//          DCLeftItemSideViewController *leftItemSideViewController = [[DCLeftItemSideViewController alloc] init];
//          return leftItemSideViewController;
            break;
        }
        case DCSideMenuOrientationPortrait: {
            DCLeftItemSideViewController *leftItemSideViewController = [[DCLeftItemSideViewController alloc] init];
            return leftItemSideViewController;
            break;
        }
        case DCSideMenuOrientationLandscape: {
            DCLeftSideMenuTableViewController *leftSideMenuTableViewController = [[DCLeftSideMenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            return leftSideMenuTableViewController;
            break;
        }
    }
    return nil;
}

- (UIViewController *)viewControllerForContentAtIndex:(NSUInteger)index {
    UIViewController *viewController = nil;
    
    UIStoryboard *storyboard = self.storyboard;
    if (!storyboard) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    }

    switch (index) {
        case 0: {
// Create view pragmaticaly/With Nib
/*
            UIViewController *vc = [[UIViewController alloc] init];
            UIViewController *vc = [[UIViewController alloc] initWithNibName:<#(NSString *)#> bundle:<#(NSBundle *)#>];
            CGFloat rand1 = arc4random() % 250;
            CGFloat rand2 = arc4random() % 250;
            CGFloat rand3 = arc4random() % 250;
            vc.view.backgroundColor = [UIColor colorWithRed:rand1/255.0f green:rand2/255.0f blue:rand3/255.0f alpha:1.0f];
            viewController = [[UINavigationController alloc] initWithRootViewController:vc];
*/
 
// Create view with storyboard
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"first"];
            break;
        }
        case 1: {
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"second"];
            break;
        }
        case 2: {
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"third"];
            break;
        }
        default: {
            [[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"You should pass nil view controller" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            break;
        }
        // Etc
    }
    
    return viewController;
}

@end
