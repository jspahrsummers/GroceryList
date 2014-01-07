//
//  GCYGroceryItemViewController.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItemViewController.h"

#import "GCYGroceryItem.h"
#import "GCYGroceryItemStoreCell.h"
#import "GCYGroceryItemStoreViewModel.h"

@interface GCYGroceryItemViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation GCYGroceryItemViewController

#pragma mark Properties

@dynamic viewModel;

#pragma mark Lifecycle

- (id)initWithViewModel:(GCYEditableGroceryItemViewModel *)viewModel {
	self = [super initWithViewModel:viewModel];
	if (self == nil) return nil;

	self.title = NSLocalizedString(@"Add Item", nil);

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:NULL];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:nil action:NULL];
	RAC(self.navigationItem.rightBarButtonItem, enabled) = self.viewModel.saveItemAction.enabled;

	RACSignal *saveCompleted = [[[self.navigationItem.rightBarButtonItem.rac_actionSignal
		mapReplace:self.viewModel.saveItemAction]
		flattenMap:^(RACAction *action) {
			return [[[action
				signalWithValue:nil]
				ignoreValues]
				concat:[RACSignal return:@YES]];
		}]
		retry];

	_saved = [RACSignal merge:@[
		[self.navigationItem.leftBarButtonItem.rac_actionSignal mapReplace:@NO],
		saveCompleted
	]];

	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = UIColor.whiteColor;
	[self.tableView registerClass:GCYGroceryItemStoreCell.class forCellReuseIdentifier:NSStringFromClass(GCYGroceryItemStoreCell.class)];

	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
	self.searchBar.placeholder = NSLocalizedString(@"Item name", nil);
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	self.searchBar.text = self.viewModel.item.name;
	self.searchBar.delegate = self;

	RAC(self, loading) = self.viewModel.saveItemAction.executing;

	@weakify(self);
	[[RACObserve(self.viewModel, stores)
		distinctUntilChanged]
		subscribeNext:^(id _) {
			@strongify(self);
			[self.tableView reloadData];
		}];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.searchBar becomeFirstResponder];
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.viewModel.editedName = searchText;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.viewModel.stores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GCYGroceryItemStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(GCYGroceryItemStoreCell.class) forIndexPath:indexPath];
	cell.viewModel = self.viewModel.stores[indexPath.row];
	return cell;
}

#pragma mark UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GCYGroceryItemStoreViewModel *store = self.viewModel.stores[indexPath.row];
	store.selected = !store.selected;

	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return self.searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44;
}

@end
