//
//  DCSideMenuController.m
//  DCSlideMenu
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import "DCSideMenuViewController.h"


@interface DCSideMenuViewController () <UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate>
{
// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//    UIDynamicAnimator *animator;
//    UICollisionBehavior *collisionBehaviour;
//    UIPushBehavior *pushBehavior;
//    UIGravityBehavior *gravityBehavior;
//    UIDynamicItemBehavior *elasticityBehavior;
    UIInterfaceOrientation cacheOrientation;
    
// DCSideMenuDataSource Cache
    BOOL dataSourceDidResponseForSelector_viewControllerForItemAtIndex;
    BOOL dataSourceDidResponseForSelector_menuWidthForOrientation;
    BOOL dataSourceDidResponseForSelector_imageForMenuBarButtonItem;
    BOOL dataSourceDidResponseForSelector_shouldBounce;
    BOOL dataSourceDidResponseForSelector_shouldStartAtIndex;
//
    
// DCSideMenuDelegate Cache
    BOOL delegateDidResponseForSelector_shouldSelectItemAtIndex;
    BOOL delegateDidResponseForSelector_willSelectItemAtIndex;
    BOOL delegateDidResponseForSelector_willDeselectItemAtIndex;
    BOOL delegateDidResponseForSelector_didSelectItemAtIndex;
    BOOL delegateDidResponseForSelector_didDeselectItemAtIndex;
//
}

//
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIViewController *selectedViewController;
@property (nonatomic, strong) NSCache *viewControllersCache;
//

@property (nonatomic, strong) UIViewController *sideMenuViewController;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *topContentView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, assign) Boolean isOpen;

@end


@implementation DCSideMenuViewController
@synthesize sideMenuViewController = _sideMenuViewController;

#pragma mark - View MGMT

- (void)viewDidLoad {
    [super viewDidLoad];
    _viewControllersCache = [[NSCache alloc] init];
    _selectedIndex = NSUIntegerMax;
    cacheOrientation = self.interfaceOrientation;
    
    [self.view addSubview:self.contentView];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self setSelectedIndex:0 animated:NO];
    
    [self _willSelectItemAtIndex:[self _shouldStartAtIndex]];
    [self restoreViewControllerStateAtIndex:[self _shouldStartAtIndex]];
    [self slideInAnimated:NO completion:^(BOOL completed1) {
        _selectedIndex = [self _shouldStartAtIndex];
        [self _didSelectItemAtIndex:_selectedIndex];
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    cacheOrientation = toInterfaceOrientation;
    
    if (self.isOpen) {
        [self slideToSideAnimated:NO completion:nil];
    } else {
        [self slideInAnimated:NO completion:nil];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Memory MGMT

- (void)didReceiveMemoryWarning {
    [self.viewControllersCache removeAllObjects];
    self.viewControllersCache = nil;
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Getters

- (UIView *)contentView {
    if (_contentView) {
        return _contentView;
    }
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor whiteColor];
    
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

- (NSString *)keyStringForIndex:(NSUInteger)idx {
    NSString *keyString = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
    return keyString;
}


#pragma mark - Setters

- (void)setDataSource:(id<DCSideMenuDataSource>)dataSource {
    if (dataSource) {
        dataSourceDidResponseForSelector_viewControllerForItemAtIndex = [dataSource respondsToSelector:@selector(viewControllerForItemAtIndex:)];
        dataSourceDidResponseForSelector_menuWidthForOrientation = [dataSource respondsToSelector:@selector(menuWidthForOrientation:)];
        dataSourceDidResponseForSelector_imageForMenuBarButtonItem = [dataSource respondsToSelector:@selector(imageForMenuBarButtonItem)];
        dataSourceDidResponseForSelector_shouldBounce = [dataSource respondsToSelector:@selector(shouldBounce)];
        dataSourceDidResponseForSelector_shouldStartAtIndex = [dataSource respondsToSelector:@selector(shouldStartAtIndex)];
        
        _dataSource = dataSource;
    }
}

- (void)setDelegate:(id<DCSideMenuDelegate>)delegate {
    if (delegate) {
        delegateDidResponseForSelector_shouldSelectItemAtIndex = [delegate respondsToSelector:@selector(sideMenuViewController:shouldSelectItemAtIndex:)];
        delegateDidResponseForSelector_willSelectItemAtIndex = [delegate respondsToSelector:@selector(sideMenuViewController:willSelectItemAtIndex:)];
        delegateDidResponseForSelector_willDeselectItemAtIndex = [delegate respondsToSelector:@selector(sideMenuViewController:willDeselectItemAtIndex:)];
        delegateDidResponseForSelector_didSelectItemAtIndex = [delegate respondsToSelector:@selector(sideMenuViewController:didSelectItemAtIndex:)];
        delegateDidResponseForSelector_didDeselectItemAtIndex = [delegate respondsToSelector:@selector(sideMenuViewController:didDeselectItemAtIndex:)];
        
        _delegate = delegate;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(Boolean)animated {
// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//    [self removeAnimation];
    self.view.userInteractionEnabled = NO;
    
    if (self.selectedIndex != selectedIndex && [self _shouldSelectItemAtIndex:selectedIndex]) {  // Exchange old UIViewController view with new UIViewController view
        if ([self.selectedViewController.view.superview isEqual:self.contentView]) {    // Exchange animation block
            [self slideOutAnimated:animated completion:^(BOOL completed0) {
                [self _willDeselectItemAtIndex:_selectedIndex];
                [self _willSelectItemAtIndex:selectedIndex];
                if (completed0) {
                    [self.selectedViewController willMoveToParentViewController:nil];
                    [self.selectedViewController removeFromParentViewController];
                    [self.selectedViewController.view removeFromSuperview];
                    
                    [self restoreViewControllerStateAtIndex:selectedIndex];
                    [self slideInAnimated:animated completion:^(BOOL completed1) {
                        [self _didDeselectItemAtIndex:_selectedIndex];
                        _selectedIndex = selectedIndex;
                        self.view.userInteractionEnabled = YES;
                        [self _didSelectItemAtIndex:_selectedIndex];
                    }];
                } else {
                    [self _didDeselectItemAtIndex:_selectedIndex];
                    self.view.userInteractionEnabled = YES;
                    [self _didSelectItemAtIndex:_selectedIndex];
                }
            }];
        } else {
            [self slideOutAnimated:animated completion:^(BOOL completed0) {
                [self _willDeselectItemAtIndex:_selectedIndex];
                [self _willSelectItemAtIndex:selectedIndex];
                if (completed0) {
                    [self restoreViewControllerStateAtIndex:selectedIndex];
                    
                    [self slideInAnimated:animated completion:^(BOOL completed1) {
                        [self _didDeselectItemAtIndex:_selectedIndex];
                        _selectedIndex = selectedIndex;
                        self.view.userInteractionEnabled = YES;
                        [self _didSelectItemAtIndex:_selectedIndex];
                    }];
                } else {
                    [self _didDeselectItemAtIndex:_selectedIndex];
                    self.view.userInteractionEnabled = YES;
                    [self _didSelectItemAtIndex:_selectedIndex];
                }
            }];
        }
    } else {    // Show animation block without view exchanging
        [self slideOutAnimated:animated completion:^(BOOL completed0) {
            [self _willDeselectItemAtIndex:_selectedIndex];
            [self _willSelectItemAtIndex:selectedIndex];
            if (completed0) {
                [self slideInAnimated:animated completion:^(BOOL completed1) {
                    [self _didDeselectItemAtIndex:_selectedIndex];
                    self.view.userInteractionEnabled = YES;
                    [self _didSelectItemAtIndex:_selectedIndex];
                }];
            } else {
                [self _didDeselectItemAtIndex:_selectedIndex];
                self.view.userInteractionEnabled = YES;
                [self _didSelectItemAtIndex:_selectedIndex];
            }
        }];
    }
}

- (void)restoreViewControllerStateAtIndex:(NSUInteger)idx {
    UIViewController *vc = [self.viewControllersCache objectForKey:[self keyStringForIndex:idx]];
    if (!vc) {
        vc = [self _viewControllerForItemAtIndex:idx];
        
        if (!vc) {
            return;
        }
        [self.viewControllersCache setObject:vc forKey:[self keyStringForIndex:idx]];
    }
    
    self.selectedViewController = vc;
    
    [self addMenuItem];
//    [self.selectedViewController willMoveToParentViewController:self];
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
        UIBarButtonItem *menuButton;
        if ([self _imageForMenuBarButtonItem]) {
            menuButton = [[UIBarButtonItem alloc] initWithImage:[self _imageForMenuBarButtonItem] style:UIBarButtonItemStyleBordered target:self action:@selector(tapAction)];
        } else {
            menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(tapAction)];
        }
        vc.navigationItem.leftBarButtonItem = menuButton;
    } else if ([self.selectedViewController isKindOfClass:[UIViewController class]]) {
        if (self.selectedViewController.navigationItem) {
            UIBarButtonItem *menuButton;
            if ([self _imageForMenuBarButtonItem]) {
              menuButton = [[UIBarButtonItem alloc] initWithImage:[self _imageForMenuBarButtonItem] style:UIBarButtonItemStyleBordered target:self action:@selector(tapAction)];
            } else {
                 menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(tapAction)];
            }
            self.selectedViewController.navigationItem.leftBarButtonItem = menuButton;
        }
    }
}

- (void)setSideMenuViewController:(UIViewController *)sideMenuViewController animated:(Boolean)animated {
    if (!sideMenuViewController) {
        NSLog(@"THE NIL");
        return;
    }
    if ([self.sideMenuViewController isEqual:sideMenuViewController]) {
        NSLog(@"THE SAME");
        return;
    }
    
    if (animated) {
        if (self.sideMenuViewController) {
            [self.sideMenuViewController willMoveToParentViewController:nil];
            [self.sideMenuViewController removeFromParentViewController];
        }
        [self addChildViewController:sideMenuViewController];

        sideMenuViewController.view.frame = self.view.bounds;
        sideMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [sideMenuViewController.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            if (self.sideMenuViewController) {
                [self.sideMenuViewController.view removeFromSuperview];
            }
            [self.view insertSubview:sideMenuViewController.view belowSubview:self.contentView];
        } completion:^(BOOL finished) {
            [sideMenuViewController didMoveToParentViewController:self];
            self.sideMenuViewController = sideMenuViewController;
        }];
    } else {
        if (self.sideMenuViewController) {
            [self.sideMenuViewController willMoveToParentViewController:nil];
            [self.sideMenuViewController removeFromParentViewController];
            [self.sideMenuViewController.view removeFromSuperview];
        }
        [self addChildViewController:sideMenuViewController];
        sideMenuViewController.view.frame = self.view.bounds;
        sideMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:sideMenuViewController.view belowSubview:self.contentView];
        [sideMenuViewController didMoveToParentViewController:self];
        self.sideMenuViewController = sideMenuViewController;
    }
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
            self.topContentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        } completion:^(BOOL finished) {
            [self removeTopContentView];
            [self enableGestureRecognizers];
            self.isOpen = NO;
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self disableGestureRecognizers];
        self.contentView.frame = CGRectMake(0.0 ,0.0, bounds.size.width, bounds.size.height);
        self.topContentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        [self removeTopContentView];
        [self enableGestureRecognizers];
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
            self.topContentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
        } completion:^(BOOL finished) {
            [self removeTopContentView];
            [self enableGestureRecognizers];
            self.isOpen = NO;
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self disableGestureRecognizers];
        self.contentView.frame = CGRectMake(bounds.size.width, 0.0, bounds.size.width, bounds.size.height);
        self.topContentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
        [self removeTopContentView];
        [self enableGestureRecognizers];
        self.isOpen = NO;
        if (completion) {
            completion(YES);
        }
    }
}

- (void)slideToSideAnimated:(Boolean)animated completion:(void (^)(BOOL completed))completion {
    CGFloat menuWidth = [self _menuWidthForOrientation:cacheOrientation];
    CGRect bounds = self.view.bounds;
    if (animated) {
        [self disableGestureRecognizers];
        [self addTopContentView];
        if ([self _shouldBounce]) {
            [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.6f options:0 animations:^{
                self.contentView.frame = CGRectMake(menuWidth, 0.0, bounds.size.width, bounds.size.height);
                self.topContentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
            } completion:^(BOOL finished) {
                [self enableGestureRecognizers];
                self.isOpen = YES;
                if (completion) {
                    completion(finished);
                }
            }];
        } else {
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.contentView.frame = CGRectMake(menuWidth, 0.0, bounds.size.width, bounds.size.height);
                self.topContentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
            } completion:^(BOOL finished) {
                [self enableGestureRecognizers];
                self.isOpen = YES;
                if (completion) {
                    completion(finished);
                }
            }];
        }
    } else {
        [self disableGestureRecognizers];
        [self addTopContentView];
        self.contentView.frame = CGRectMake(menuWidth, 0.0, bounds.size.width, bounds.size.height);
        self.topContentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        [self enableGestureRecognizers];
        self.isOpen = YES;
        if (completion) {
            completion(YES);
        }
    }
}

- (void)enableGestureRecognizers {
    self.panGestureRecognizer.enabled = YES;
    self.topContentView.userInteractionEnabled = YES;
}

- (void)disableGestureRecognizers {
    self.panGestureRecognizer.enabled = NO;
    self.topContentView.userInteractionEnabled = NO;
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
    
    CGFloat menuWidth = [self _menuWidthForOrientation:cacheOrientation];
    
    if ([gesture state] == UIGestureRecognizerStateBegan) {
// TODO: Uncomment when fix "UIDynamicAnimator weird animation"
//        [self removeAnimation];
        if (movingView.frame.origin.x + translation.x < 0 ) {
            translation.x = 0.0;
        }
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {

// UIView animation

        CGPoint velocity = [gesture velocityInView:self.view];
        CGFloat xPoints = menuWidth-self.view.frame.size.width/2.0f;
#if CGFLOAT_IS_DOUBLE
        CGFloat duration = xPoints / fabs(velocity.x);
#else
        CGFloat duration = xPoints / fabsf(velocity.x);
#endif
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
        } else if (movingView.frame.origin.x + translation.x > menuWidth) {
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

- (UIViewController *)_viewControllerForItemAtIndex:(NSUInteger)idx {
    if (dataSourceDidResponseForSelector_viewControllerForItemAtIndex) {
        return [self.dataSource viewControllerForItemAtIndex:idx];
    }
    return nil;
}

- (CGFloat)_menuWidthForOrientation:(UIInterfaceOrientation)orientation {
    if (dataSourceDidResponseForSelector_menuWidthForOrientation) {
        return [self.dataSource menuWidthForOrientation:cacheOrientation];
    }
    return 230.0f;
}

- (UIImage *)_imageForMenuBarButtonItem {
    if (dataSourceDidResponseForSelector_imageForMenuBarButtonItem) {
        return [self.dataSource imageForMenuBarButtonItem];
    }
    return nil;
}

- (Boolean)_shouldBounce {
    if (dataSourceDidResponseForSelector_shouldBounce) {
        return [self.dataSource shouldBounce];
    }
    return YES;
}

- (NSUInteger)_shouldStartAtIndex {
    if (dataSourceDidResponseForSelector_shouldStartAtIndex) {
        return [self.dataSource shouldStartAtIndex];
    }
    return 0;
}

#pragma mark - DCSideMenuDelegate

- (BOOL)_shouldSelectItemAtIndex:(NSUInteger)idx {
    if (delegateDidResponseForSelector_shouldSelectItemAtIndex) {
        return [self.delegate sideMenuViewController:self shouldSelectItemAtIndex:idx];
    }
    return YES;
}

- (void)_willSelectItemAtIndex:(NSUInteger)idx {
    if (delegateDidResponseForSelector_willSelectItemAtIndex) {
        [self.delegate sideMenuViewController:self willSelectItemAtIndex:idx];
    }
}

- (void)_willDeselectItemAtIndex:(NSUInteger)idx {
    if (delegateDidResponseForSelector_willDeselectItemAtIndex) {
        [self.delegate sideMenuViewController:self willDeselectItemAtIndex:idx];
    }
}

- (void)_didSelectItemAtIndex:(NSUInteger)idx {
    if (delegateDidResponseForSelector_didSelectItemAtIndex) {
        [self.delegate sideMenuViewController:self didSelectItemAtIndex:idx];
    }
}

- (void)_didDeselectItemAtIndex:(NSUInteger)idx {
    if (delegateDidResponseForSelector_didDeselectItemAtIndex) {
        [self.delegate sideMenuViewController:self didDeselectItemAtIndex:idx];
    }
}

@end
