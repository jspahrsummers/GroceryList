//
//  GCYGroceryStoreListViewController.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryStoreListViewController.h"

#import "GCYGroceryStoreCell.h"
#import "GCYGroceryStoreViewModel.h"

@implementation GCYGroceryStoreListViewController

#pragma mark Properties

@dynamic viewModel;

#pragma mark Lifecycle

- (instancetype)initWithViewModel:(GCYGroceryStoreListViewModel *)viewModel {
	self = [super initWithViewModel:viewModel];
	if (self == nil) return nil;

	@weakify(self);

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:NULL];

	RACSignal *dismissed = [self.navigationItem.leftBarButtonItem.rac_actionSignal mapReplace:nil];
	RACSignal *selected = [[self
		rac_signalForSelector:@selector(tableView:willSelectRowAtIndexPath:)]
		reduceEach:^(id _, NSIndexPath *indexPath) {
			@strongify(self);
			return self.viewModel.stores[indexPath.row];
		}];

	_selectedStore = [RACSignal merge:@[
		dismissed,
		selected
	]];

	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = NSLocalizedString(@"Stores", nil);
	self.view.backgroundColor = UIColor.whiteColor;

	[self.tableView registerClass:GCYGroceryStoreCell.class forCellReuseIdentifier:NSStringFromClass(GCYGroceryStoreCell.class)];

	@weakify(self);
	[[RACObserve(self.viewModel, stores)
		distinctUntilChanged]
		subscribeNext:^(id _) {
			@strongify(self);
			[self.tableView reloadData];
		}];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.viewModel.stores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GCYGroceryStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(GCYGroceryStoreCell.class) forIndexPath:indexPath];
	cell.viewModel = self.viewModel.stores[indexPath.row];
	return cell;
}

#pragma mark UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
