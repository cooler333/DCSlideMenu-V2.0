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

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define isPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height != 568)
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


@interface DCSideMenuViewControllerSubclass () <DCSideMenuDataSource, DCSideMenuDelegate, DCSideMenuCacheDelegate>

@property (nonatomic, strong) DCLeftSideMenuTableViewController *vc1;
@property (nonatomic, strong) DCLeftItemSideViewController *vc2;

@end


@implementation DCSideMenuViewControllerSubclass

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.cacheDelegate = self;
    
    self.vc1 = [[DCLeftSideMenuTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.vc2 = [[DCLeftItemSideViewController alloc] init];
    [self setSideMenuViewController:self.vc1 animated:NO];
}

// Change sideMenuViewController when view rotated;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self setSideMenuViewController:self.vc1 animated:NO];
    } else {
        [self setSideMenuViewController:self.vc2 animated:NO];
    }
}


#pragma mark - DCSideMenuDataSource

- (UIViewController *)viewControllerForItemAtIndex:(NSUInteger)index {
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

- (CGFloat)menuWidthForOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        if (isPhone) {
            return 250.0f;
        } else if (isPhone568) {
            return 250.0f;
        } else if (isPad) {
            return 400.0f;
        }
    } else {
        if (isPhone) {
            return 250.0f;
        } else if (isPhone568) {
            return 300.0f;
        } else if (isPad) {
            return 400.0f;
        }
    }
    return 280.0f;
}

- (UIImage *)imageForMenuBarButtonItem {
//    return [UIImage imageNamed:@"menu"];
    return nil;
}

- (BOOL)shouldBounce {
    return YES;
}

#pragma mark - DCSideMenuDelegate

- (BOOL)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController shouldSelectItemAtIndex:(NSUInteger)idx {
    if (idx == 4) {
        return NO;
    }
    return YES;
}

- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController willSelectItemAtIndex:(NSUInteger)idx {
    NSLog(@"sideMenuViewController willSelectItemAtIndex: %lu", (unsigned long)idx);
}

- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController willDeselectItemAtIndex:(NSUInteger)idx {
    NSLog(@"sideMenuViewController willDeselectItemAtIndex: %lu", (unsigned long)idx);
}

- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController didSelectItemAtIndex:(NSUInteger)idx {
    NSLog(@"sideMenuViewController didSelectItemAtIndex: %lu", (unsigned long)idx);
}

- (void)sideMenuViewController:(DCSideMenuViewController *)sideMenuViewController didDeselectItemAtIndex:(NSUInteger)idx {
    NSLog(@"sideMenuViewController didDeselectItemAtIndex: %lu", (unsigned long)idx);
}

#pragma mark - DCSideMenuCacheDelegate

- (void)cacheWillDeallocViewController:(UIViewController *)viewController {
    // Perform save before dealloc
    NSLog(@"%@", viewController);
}

@end
