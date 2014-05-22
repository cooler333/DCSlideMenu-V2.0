//
//  DCSideMenuController.m
//  DCSlideMenu
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import "DCSideMenuController.h"

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define isPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height != 568)
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


@interface DCSideMenuController () <UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate>
{
// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//    UIDynamicAnimator *animator;
//    UICollisionBehavior *collisionBehaviour;
//    UIPushBehavior *pushBehavior;
//    UIGravityBehavior *gravityBehavior;
//    UIDynamicItemBehavior *elasticityBehavior;
    UIInterfaceOrientation cacheOrientation;
}

//
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIViewController *selectedViewController;
@property (nonatomic, strong) NSCache *viewControllersCache;
@property (nonatomic, strong) NSCache *leftMenuViewControllersCache;
//

@property (nonatomic, strong) UIViewController *leftMenuController;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *topContentView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, assign) Boolean isOpen;

@end


@implementation DCSideMenuController
@synthesize leftMenuController = _leftMenuController;

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        [self configureViewController];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureViewController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self configureViewController];
    }
    return self;
}

- (void)configureViewController {
// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
//    animator.delegate = self;
    
    _viewControllersCache = [[NSCache alloc] init];
    _selectedIndex = NSUIntegerMax;

    [self.view addSubview:self.contentView];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    UIViewController *vc = [self.dataSource viewControllerForLeftMenuOrientation:DCSideMenuOrientationAll];
    if (!vc) {
        vc = [self.dataSource viewControllerForLeftMenuOrientation:DCSideMenuOrientationPortrait];
    }
    if (!vc) {
        vc = [self.dataSource viewControllerForLeftMenuOrientation:DCSideMenuOrientationLandscape];
    }
    [self setLeftMenuController:vc animated:NO];
    [self setSelectedIndex:0 animated:NO];
}

#pragma mark - View MGMT

- (void)loadView {
    [super loadView];
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {  // Remove redundant subviews
        [obj removeFromSuperview];
        obj = nil;
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    UIViewController *vc = [self.dataSource viewControllerForLeftMenuOrientation:DCSideMenuOrientationAll];
    if (!vc) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            vc = [self.dataSource viewControllerForLeftMenuOrientation:DCSideMenuOrientationLandscape];
        } else {
            vc = [self.dataSource viewControllerForLeftMenuOrientation:DCSideMenuOrientationPortrait];
        }
    }
    [self setLeftMenuController:vc animated:NO];
    cacheOrientation = toInterfaceOrientation;
    
    if (self.isOpen) {
        [self slideToSideAnimated:NO completion:nil];
    } else {
        [self slideInAnimated:NO completion:nil];
    }
}

- (void)configureView {
    //
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Memory MGMT

- (void)didReceiveMemoryWarning {
    self.leftMenuController = nil;
    self.selectedViewController = nil;
    
    [self.viewControllersCache removeAllObjects];
    self.viewControllersCache = nil;
    [super didReceiveMemoryWarning];
}

- (void)releaseView {

    self.contentView = nil;
    self.topContentView = nil;
    self.panGestureRecognizer = nil;
}

#pragma mark - Getters

- (UIView *)contentView {
    if (_contentView) {
        return _contentView;
    }
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor redColor];    
    
    _contentView = view;
    return _contentView;
}

- (UIButton *)topContentView {
    if (_topContentView) {
        return _topContentView;
    }
    UIButton *button = [[UIButton alloc] initWithFrame:self.view.bounds];
    [button addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    button.backgroundColor = [UIColor clearColor];

    _topContentView = button;
    return _topContentView;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (_panGestureRecognizer) {
        return _panGestureRecognizer;
    }
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [panGestureRecognizer setMaximumNumberOfTouches:2];
    
    _panGestureRecognizer = panGestureRecognizer;
    return _panGestureRecognizer;
}

- (CGFloat)menuSize {
    if (isPhone || isPhone568) {
        if (UIInterfaceOrientationIsLandscape(cacheOrientation)) {
            if (self.phoneLandscapeMenuWidth > 0.0f) {
                return self.phoneLandscapeMenuWidth;
            }
        } else {
            if (self.phonePortraitMenuWidth > 0.0f) {
                return self.phonePortraitMenuWidth;
            }
        }
    } else if (isPad) {
        if (UIInterfaceOrientationIsLandscape(cacheOrientation)) {
            if (self.padLandscapeMenuWidth > 0.0f) {
                return self.padLandscapeMenuWidth;
            }
        } else {
            if (self.padPortraitMenuWidth > 0.0f) {
                return self.padPortraitMenuWidth;
            }
        }
    }
    return 230.0f;
}

- (NSString *)keyStringForIndex:(NSUInteger)index {
    NSString *keyString = [NSString stringWithFormat:@"%lu", index];
    return keyString;
}


#pragma mark - Setters

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(Boolean)animated {
// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//    [self removeAnimation];
    self.view.userInteractionEnabled = NO;
    if (self.selectedIndex != selectedIndex) {  // Exchange old UIViewController view with new UIViewController view
        if ([self.selectedViewController.view.superview isEqual:self.contentView]) {    // Exchange animation block
            [self slideOutAnimated:animated completion:^(BOOL completed) {
                [self.selectedViewController.view removeFromSuperview];
                
                _selectedIndex = selectedIndex;
                [self restoreViewControllerStateAtIndex:_selectedIndex];
                
                [self slideInAnimated:animated completion:^(BOOL completed) {
                    self.view.userInteractionEnabled = YES;
                }];
            }];
        } else {    // Add new UIViewController view
            [self slideOutAnimated:animated completion:^(BOOL completed) {
                _selectedIndex = selectedIndex;
                [self restoreViewControllerStateAtIndex:_selectedIndex];
                [self slideInAnimated:animated completion:^(BOOL completed) {
                    self.view.userInteractionEnabled = YES;
                }];
            }];
        }
    } else {    // Show animation block without view exchanging
        [self slideOutAnimated:animated completion:^(BOOL completed) {
            [self slideInAnimated:animated completion:^(BOOL completed) {
                self.view.userInteractionEnabled = YES;
            }];
        }];
    }
}

- (void)restoreViewControllerStateAtIndex:(NSUInteger)index {
    UIViewController *vc = [self.viewControllersCache objectForKey:[self keyStringForIndex:index]];
    if (!vc) {
        vc = [self viewControllerForContentAtIndex:index];
        if (!vc) {
            return;
        }
        [self.viewControllersCache setObject:vc forKey:[self keyStringForIndex:index]];
    }
    
    self.selectedViewController = vc;
    
    [self addMenuItem];
    [self.selectedViewController willMoveToParentViewController:self];
    [self addChildViewController:self.selectedViewController];
    [self.contentView addSubview:self.selectedViewController.view];
    self.selectedViewController.view.frame = self.contentView.bounds;
    self.selectedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.selectedViewController didMoveToParentViewController:self];
}

- (void)addMenuItem {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nvc = (UINavigationController *)self.selectedViewController;
        UIViewController *vc = [nvc.viewControllers objectAtIndex:0];
        //  UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(tapAction)];
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"MENU" style:UIBarButtonItemStyleBordered target:self action:@selector(tapAction)];
        vc.navigationItem.leftBarButtonItem = menuButton;
    } else if ([self.selectedViewController isKindOfClass:[UIViewController class]]) {
        if (self.selectedViewController.navigationItem) {
            //  UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(tapAction)];
            UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"MENU" style:UIBarButtonItemStyleBordered target:self action:@selector(tapAction)];
            self.selectedViewController.navigationItem.leftBarButtonItem = menuButton;
        }
    }
}

- (void)setLeftMenuController:(UIViewController *)leftMenuController animated:(Boolean)animated {
    if (self.leftMenuController) {
        [self.leftMenuController willMoveToParentViewController:nil];
        [self.leftMenuController removeFromParentViewController];
        [self.leftMenuController.view removeFromSuperview];
        [self.leftMenuController didMoveToParentViewController:nil];
    }
    if (leftMenuController) {
        [leftMenuController willMoveToParentViewController:self];
        [self addChildViewController:leftMenuController];
        [self.view insertSubview:leftMenuController.view belowSubview:self.contentView];
        leftMenuController.view.frame = self.view.bounds;
        leftMenuController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [leftMenuController didMoveToParentViewController:self];
    }
    self.leftMenuController = leftMenuController;
}

#pragma mark - Public Methods
//

#pragma mark - Private Methods

// Slide animation
- (void)slideInAnimated:(Boolean)animated completion:(void (^)(BOOL completed))completion {
    CGRect bounds = self.view.bounds;
    if (animated) {
        [self disableGestureRecognizers];
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.contentView.frame = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
        } completion:^(BOOL finished) {
            [self enableGestureRecognizers];
            [self removeTopContentView];
            self.isOpen = NO;
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self disableGestureRecognizers];
        self.contentView.frame = CGRectMake(0.0 ,0.0, bounds.size.width, bounds.size.height);
        [self enableGestureRecognizers];
        [self removeTopContentView];
        self.isOpen = NO;
        if (completion) {
            completion(YES);
        }
    }
}

- (void)slideOutAnimated:(Boolean)animated completion:(void (^)(BOOL completed))completion {
    CGRect bounds = self.view.bounds;
    if (animated) {
        [self disableGestureRecognizers];
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.contentView.frame = CGRectMake(bounds.size.width, 0.0, bounds.size.width, bounds.size.height);
        } completion:^(BOOL finished) {
            [self enableGestureRecognizers];
            [self removeTopContentView];
            self.isOpen = NO;
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self disableGestureRecognizers];
        self.contentView.frame = CGRectMake(bounds.size.width, 0.0, bounds.size.width, bounds.size.height);
        [self enableGestureRecognizers];
        [self removeTopContentView];
        self.isOpen = NO;
        if (completion) {
            completion(YES);
        }
    }
}

- (void)slideToSideAnimated:(Boolean)animated completion:(void (^)(BOOL completed))completion {
    CGRect bounds = self.view.bounds;
    if (animated) {
        [self disableGestureRecognizers];
        if (self.shouldBounce) {
            [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.6f options:0 animations:^{
                self.contentView.frame = CGRectMake(self.menuSize, 0.0, bounds.size.width, bounds.size.height);
            } completion:^(BOOL finished) {
                [self enableGestureRecognizers];
                [self addTopContentView];
                self.isOpen = YES;
                if (completion) {
                    completion(finished);
                }
            }];
        } else {
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.contentView.frame = CGRectMake(self.menuSize, 0.0, bounds.size.width, bounds.size.height);
            } completion:^(BOOL finished) {
                [self enableGestureRecognizers];
                [self addTopContentView];
                self.isOpen = YES;
                if (completion) {
                    completion(finished);
                }
            }];
        }
    } else {
        [self disableGestureRecognizers];
        self.contentView.frame = CGRectMake(self.menuSize, 0.0, bounds.size.width, bounds.size.height);
        [self enableGestureRecognizers];
        [self addTopContentView];
        self.isOpen = YES;
        if (completion) {
            completion(YES);
        }
    }
}

- (void)enableGestureRecognizers {
    [self.panGestureRecognizer setEnabled:YES];
}

- (void)disableGestureRecognizers {
    [self.panGestureRecognizer setEnabled:NO];
}

- (void)addTopContentView {
    [self.contentView addSubview:self.topContentView];
    self.topContentView.frame = self.contentView.bounds;
}
- (void)removeTopContentView {
    [self.topContentView removeFromSuperview];
}

// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//- (void)removeAnimation {
//    for (UIDynamicBehavior *behavior in animator.behaviors) {
//        [animator removeBehavior:behavior];
//    }
//}

- (void)tapAction {
    if (self.isOpen) {
        [self slideInAnimated:YES completion:nil];
    } else {
        [self slideToSideAnimated:YES completion:nil];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)gesture {
    UIView *panningView = self.view;
    CGPoint translation = [gesture translationInView:panningView];
    UIView *movingView = self.contentView;
    
    if ([gesture state] == UIGestureRecognizerStateBegan) {
// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//        [self removeAnimation];
        if (movingView.frame.origin.x + translation.x < 0 ) {
            translation.x = 0.0;
        }
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {

// UIView animation

        CGPoint velocity = [gesture velocityInView:self.view];
        CGFloat xPoints = self.menuSize-self.view.frame.size.width/2.0f;
        NSTimeInterval duration = xPoints / fabsf(velocity.x);
        if (duration > 0.7f) {
            duration = 0.7f;
        } else if (duration < 0.4f) {
            duration = 0.4f;
        }
        
        CGFloat velocityX = 0.0f;
        if (velocity.x > -velocityX && velocity.x < 0.0f) {
            velocity.x = -velocityX;
        } else if (velocity.x < velocityX && velocity.x >= 0.0f) {
            velocity.x = velocityX;
        } else if (velocity.x < -1000.0f && velocity.x < 0.0f) {
            velocity.x = -1000.0f;
        }
        velocity.x = velocity.x/2.0f;
        
        if (velocity.x < xPoints) {
            [self slideInAnimated:YES completion:nil];
        } else {
            [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:duration options:0 animations:^{
                [self slideToSideAnimated:NO completion:nil];
            } completion:nil];
        }

// FIXME: UIDynamicAnimator weird animation
// UIDynamicAnimator animation
/*
        CGFloat t = self.contentView.frame.origin.x;
        CGFloat centerEdge = self.view.frame.size.width/2.0f;
        CGPoint velocity = [gesture velocityInView:self.view];
        
        CGFloat velocityX = 0.0f;
        if (velocity.x >= -velocityX && velocity.x <= 0.0f) {
            velocity.x = -velocityX;
        } else if (velocity.x <= velocityX && velocity.x >= 0.0f) {
            velocity.x = velocityX;
        } else if (velocity.x <= -1000.0f && velocity.x <= 0.0f) {
            velocity.x = -1000.0f;
        }
        
        CGPoint point = CGPointMake(movingView.frame.origin.x + translation.x + velocity.x, movingView.frame.origin.y);
        NSLog(@"POINT_X: %f", point.x);
        
        collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.contentView]];
        collisionBehaviour.translatesReferenceBoundsIntoBoundary = NO;
        collisionBehaviour.collisionDelegate = self;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width+self.menuSize, self.view.bounds.size.height)];
        [collisionBehaviour addBoundaryWithIdentifier:@"rect" forPath:path];
        
        pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.contentView] mode:UIPushBehaviorModeContinuous];
        pushBehavior.pushDirection = CGVectorMake(velocity.x, 0.0f);
        pushBehavior.active = YES;
        
        elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.contentView]];
        elasticityBehavior.elasticity = 0.4f;
        elasticityBehavior.allowsRotation = NO;
        
        gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.contentView]];
        if (t < centerEdge) {
            gravityBehavior.gravityDirection = CGVectorMake(-1.0f, 0.0f);
        } else {
            gravityBehavior.gravityDirection = CGVectorMake(1.0f, 0.0f);
        }

        [animator addBehavior:collisionBehaviour];
        [animator addBehavior:pushBehavior];
        [animator addBehavior:elasticityBehavior];
        [animator addBehavior:gravityBehavior];
*/
    } else {
        if (movingView.frame.origin.x + translation.x < 0.0f ) {
            translation.x = 0.0f;
        } else if (movingView.frame.origin.x + translation.x > self.menuSize) {
            translation.x = 0.0f;
        }
        
        movingView.center = CGPointMake([movingView center].x + translation.x, [movingView center].y);
        [gesture setTranslation:CGPointZero inView:[panningView superview]];
    }
}

// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//#pragma mark - UIDynamicAnimatorDelegate
//
//- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)a{
//    [self removeAnimation];
//    
//    CGFloat t = self.contentView.frame.origin.x;
//    CGFloat centerEdge = self.view.frame.size.width/2.0f;
//    
//    if (t <= centerEdge) {
//        [self slideInAnimated:YES completion:nil];
//    } else {
//        [self slideToSideAnimated:YES completion:nil];
//    }
//}
//
//- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator{
//    //
//}
//
//#pragma mark - UICollisionBehaviorDelegate
//
//- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p {
//    NSLog(@"%s %f", __PRETTY_FUNCTION__, p.x);
//}
//
//- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 {
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, item1);
//}
//
//// The identifier of a boundary created with translatesReferenceBoundsIntoBoundary or setTranslatesReferenceBoundsIntoBoundaryWithInsets is nil
//- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier atPoint:(CGPoint)p {
//        NSLog(@"%s %f %@", __PRETTY_FUNCTION__, p.x, identifier);
//}
//
//- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier {
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, identifier);
//}

#pragma mark - DCSideMenuDataSource

- (UIViewController *)viewControllerForLeftMenuOrientation:(DCSideMenuOrientation)orientation {
    if ([self.dataSource respondsToSelector:@selector(viewControllerForLeftMenuOrientation:)]) {
        return [self.dataSource viewControllerForLeftMenuOrientation:orientation];
    }
    return nil;
}

- (UIViewController *)viewControllerForContentAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(viewControllerForContentAtIndex:)]) {
        return [self.dataSource viewControllerForContentAtIndex:index];
    }
    return nil;
}

@end
