//
//  DCLeftSideMenuTableViewController.m
//  DCSlideMenu(TabBar)
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 Dmitry Coolerov. All rights reserved.
//


#import "DCLeftSideMenuTableViewController.h"
#import "DCSideMenuViewControllerSubclass.h"


@interface DCLeftSideMenuTableViewController ()

@end


@implementation DCLeftSideMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Private Methods

- (NSUInteger)currentIndex:(NSIndexPath *)indexPath {
    NSUInteger currentIndex = 0;
    for(NSInteger i = 0 ; i <= indexPath.section-1 ; i++) {
        NSUInteger numberOfRowInSection = [self.tableView numberOfRowsInSection:i];
        currentIndex = currentIndex + numberOfRowInSection;;
    }
    currentIndex = currentIndex + indexPath.row;
    
    return currentIndex;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"menuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"SECTION: %li ROW: %li", (long)indexPath.section, (long)indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
// Calculate index
        NSUInteger index = [self currentIndex:indexPath];
// To select UIViewController use (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(Boolean)animated
        [(DCSideMenuViewControllerSubclass *)self.parentViewController setSelectedIndex:index animated:YES];
    }
}

@end
