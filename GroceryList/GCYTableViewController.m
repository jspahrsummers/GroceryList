//
//  GCYTableViewController.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYTableViewController.h"

@implementation GCYTableViewController

#pragma mark Properties

- (UITableView *)tableView {
	return self.childTableViewController.tableView;
}

#pragma mark Lifecycle

- (id)initWithViewModel:(GCYViewModel *)viewModel nibName:(NSString *)nibName bundle:(NSBundle *)bundle {
	self = [super initWithViewModel:viewModel nibName:nibName bundle:bundle];
	if (self == nil) return nil;

	_childTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	[self addChildViewController:self.childTableViewController];
	[self.childTableViewController didMoveToParentViewController:self];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.tableView.frame = self.view.bounds;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view insertSubview:self.tableView atIndex:0];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSAssert(NO, @"This method must be overridden by subclasses");
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSAssert(NO, @"This method must be overridden by subclasses");
	return nil;
}

@end
