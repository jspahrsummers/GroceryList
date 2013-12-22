//
//  GCYGroceryStoreListViewController.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYTableViewController.h"
#import "GCYGroceryStoreListViewModel.h"

@interface GCYGroceryStoreListViewController : GCYTableViewController

@property (nonatomic, strong, readonly) GCYGroceryStoreListViewModel *viewModel;

// Sends a `GCYGroceryStoreViewModel` when the user selects one to switch to, or
// nil if the user dismissed the list without selecting a store.
@property (nonatomic, strong, readonly) RACSignal *selectedStore;

@end
