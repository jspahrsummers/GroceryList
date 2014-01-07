//
//  GCYGroceryListViewController.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryListViewController.h"

#import "GCYGroceryItem.h"
#import "GCYGroceryItemCell.h"
#import "GCYGroceryItemViewController.h"
#import "GCYGroceryItemViewModel.h"
#import "GCYGroceryStore.h"
#import "GCYGroceryStoreViewModel.h"
#import "GCYGroceryStoreListViewController.h"

#import <ReactiveCocoa/UIRefreshControl+RACSupport.h>

@implementation GCYGroceryListViewController

#pragma mark Properties

@dynamic viewModel;

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	@weakify(self);

	RAC(self, title) = RACObserve(self.viewModel, store.displayName);

	self.view.backgroundColor = UIColor.whiteColor;

	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[[[refreshControl
		rac_signalForControlEvents:UIControlEventValueChanged]
		mapReplace:self.viewModel.loadItemsAction]
		subscribeNext:^(RACAction *action) {
			[action execute:nil];
		}];

	self.childTableViewController.refreshControl = refreshControl;

	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done Shopping", nil) style:UIBarButtonItemStylePlain target:nil action:NULL];

	// TODO: This should be easier.
	RAC(doneItem, enabled) = self.viewModel.doneShoppingAction.enabled;
	[[doneItem.rac_actionSignal
		flattenMap:^(UIBarButtonItem *item) {
			return [RACSignal defer:^{
				UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"This will delete the crossed-off items. Are you sure?", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:nil];
				[actionSheet showFromBarButtonItem:item animated:YES];

				return [actionSheet.rac_buttonClickedSignal filter:^ BOOL (NSNumber *index) {
					return index.integerValue == actionSheet.destructiveButtonIndex;
				}];
			}];
		}]
		subscribeNext:^(id _) {
			[self.viewModel.doneShoppingAction execute:nil];
		}];

	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	toolbar.items = @[
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
		doneItem,
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
	];

	[self.view addSubview:toolbar];

	RACTupleUnpack(RACSignal *toolbarFrame, RACSignal *tableFrame) = [[self.view.rcl_boundsSignal
		// FIXME: /khanify RCL
		take:1]
		divideWithAmount:RCLBox(44) fromEdge:NSLayoutAttributeBottom];

	RAC(toolbar, frame) = toolbarFrame;
	RAC(self.tableView, frame) = tableFrame;

	// TODO: Better icon for this button.
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:nil action:NULL];
	RAC(self.navigationItem.leftBarButtonItem, enabled) = self.viewModel.switchListsAction.enabled;

	RAC(self.viewModel, store) = [[[[[self.navigationItem.leftBarButtonItem.rac_actionSignal
		mapReplace:self.viewModel.switchListsAction]
		flattenMap:^(RACAction *action) {
			return [[action
				signalWithValue:nil]
				catchTo:[RACSignal empty]];
		}]
		map:^(GCYGroceryStoreListViewModel *viewModel) {
			return [[GCYGroceryStoreListViewController alloc] initWithViewModel:viewModel];
		}]
		map:^(GCYGroceryStoreListViewController *viewController) {
			@strongify(self);
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

			return [[[[[self
				rcl_presentViewController:navController animated:YES]
				concat:viewController.selectedStore]
				take:1]
				ignore:nil]
				concat:[self rcl_dismissViewControllerAnimated:YES]];
		}]
		concat];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:NULL];
	self.navigationItem.rightBarButtonItem.rac_action = self.viewModel.addItemAction;

	[self.tableView registerClass:GCYGroceryItemCell.class forCellReuseIdentifier:NSStringFromClass(GCYGroceryItemCell.class)];

	[[RACObserve(self.viewModel, items)
		distinctUntilChanged]
		subscribeNext:^(id _) {
			@strongify(self);
			[self.tableView reloadData];
		}];
	
	[[[[[[RACObserve(self.viewModel, editingItem)
		ignore:nil]
		map:^(GCYEditableGroceryItemViewModel *viewModel) {
			return [[GCYGroceryItemViewController alloc] initWithViewModel:viewModel];
		}]
		map:^(GCYGroceryItemViewController *viewController) {
			@strongify(self);
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];

			return [[[[self
				rcl_presentViewController:navController animated:YES]
				concat:viewController.saved]
				take:1]
				concat:[self rcl_dismissViewControllerAnimated:YES]];
		}]
		concat]
		mapReplace:self.viewModel.loadItemsAction]
		subscribeNext:^(RACAction *action) {
			// TODO: Move to view model.
			[action execute:nil];
		}];

	[[[[[RACSignal
		combineLatest:@[
			self.viewModel.signInAction.executing,
			self.viewModel.loadItemsAction.executing,
			self.viewModel.removeItemAction.executing,
			self.viewModel.doneShoppingAction.executing,
		]]
		or]
		skipWhile:^ BOOL (NSNumber *loading) {
			// Skip until we start loading.
			return !loading.boolValue;
		}]
		distinctUntilChanged]
		subscribeNext:^(NSNumber *loading) {
			@strongify(self);

			if (loading.boolValue) {
				[refreshControl beginRefreshing];
				[self.tableView setContentOffset:CGPointMake(0, -refreshControl.frame.size.height) animated:YES];
			} else {
				[refreshControl endRefreshing];
				[self.tableView setContentOffset:CGPointZero animated:YES];
			}
		}];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (NSInteger)self.viewModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GCYGroceryItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(GCYGroceryItemCell.class) forIndexPath:indexPath];
	cell.viewModel = self.viewModel.items[indexPath.row];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSParameterAssert(editingStyle == UITableViewCellEditingStyleDelete);

	GCYGroceryItemViewModel *item = self.viewModel.items[indexPath.row];
	[self.viewModel.removeItemAction execute:item.item];
}

#pragma mark UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GCYGroceryItemViewModel *item = self.viewModel.items[indexPath.row];
	item.inCart = !item.inCart;

	return nil;
}

@end
