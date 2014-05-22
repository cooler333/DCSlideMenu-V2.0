//
//  DCLeftItemSideViewController.m
//  DCSlideMenu(TabBar)
//
//  Created by Admin on 21.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import "DCLeftItemSideViewController.h"
#import "DCSideMenuViewControllerSubclass.h"


@interface DCLeftItemSideViewController ()

@end


@implementation DCLeftItemSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button0 = [UIButton buttonWithType:UIButtonTypeSystem];
    button0.frame = CGRectMake(0.0f, 40.0f, 100.0f, 40.0f);
    [button0 addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [button0 setTitle:@"First" forState:UIControlStateNormal];
    [button0 setBackgroundColor:[UIColor whiteColor]];
    button0.tag = 0;
    [self.view addSubview:button0];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button1.frame = CGRectMake(0.0f, 80.0f, 100.0f, 40.0f);
    [button1 addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"Second" forState:UIControlStateNormal];
    [button1 setBackgroundColor:[UIColor whiteColor]];
    button1.tag = 1;
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame = CGRectMake(0.0f, 120.0f, 100.0f, 40.0f);
    [button2 addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"Third" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor whiteColor]];
    button2.tag = 2;
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    button3.frame = CGRectMake(0.0f, 160.0f, 100.0f, 40.0f);
    [button3 addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitle:@"Fourth" forState:UIControlStateNormal];
    [button3 setBackgroundColor:[UIColor whiteColor]];
    button3.tag = 3;
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    button4.frame = CGRectMake(0.0f, 200.0f, 100.0f, 40.0f);
    [button4 addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [button4 setTitle:@"Last" forState:UIControlStateNormal];
    [button4 setBackgroundColor:[UIColor whiteColor]];
    button4.tag = 4;
    [self.view addSubview:button4];
}

- (void)tap:(UIButton *)button {
// To select UIViewController use (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(Boolean)animated
    [(DCSideMenuViewControllerSubclass *)self.parentViewController setSelectedIndex:button.tag animated:YES];
}

@end
