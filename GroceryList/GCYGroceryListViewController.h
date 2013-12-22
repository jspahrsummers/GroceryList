//
//  GCYGroceryListViewController.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYTableViewController.h"
#import "GCYGroceryListViewModel.h"

@interface GCYGroceryListViewController : GCYTableViewController

@property (nonatomic, strong, readonly) GCYGroceryListViewModel *viewModel;

@end
