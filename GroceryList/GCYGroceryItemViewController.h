//
//  GCYGroceryItemViewController.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYTableViewController.h"
#import "GCYEditableGroceryItemViewModel.h"

// Allows the user to add or edit an item.
@interface GCYGroceryItemViewController : GCYTableViewController

@property (nonatomic, strong, readonly) GCYEditableGroceryItemViewModel *viewModel;

// Sends YES when the user successfully saves their changes, or NO when the user
// cancels editing.
@property (nonatomic, strong, readonly) RACSignal *saved;

@end
