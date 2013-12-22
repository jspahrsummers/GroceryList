//
//  GCYGroceryListViewModel.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewModel.h"

@class GCYEditableGroceryItemViewModel;
@class GCYGroceryStoreViewModel;

@interface GCYGroceryListViewModel : GCYViewModel

// The `GCYGroceryItemViewModel`s in the grocery list, in the order they should
// be displayed to the user.
//
// This will be `nil` before the list has been loaded for the first time.
@property (nonatomic, copy, readonly) NSArray *items;

// The store whose items are being displayed right now, or `nil` if no store is
// selected.
@property (nonatomic, strong) GCYGroceryStoreViewModel *store;

// Invoked when the user asks to switch lists.
//
// Sends a `GCYGroceryStoreListViewModel` upon success.
@property (nonatomic, strong, readonly) RACAction *switchListsAction;

// Asks the user to sign in, or automatically signs in if possible.
//
// This will be automatically executed when the view model becomes active.
@property (nonatomic, strong, readonly) RACAction *signInAction;

// Loads the items in the grocery list, updating the `items` property upon
// success.
//
// This will be automatically executed when the view model becomes active.
@property (nonatomic, strong, readonly) RACAction *loadItemsAction;

// Any item currently being edited or added.
@property (nonatomic, strong, readonly) GCYEditableGroceryItemViewModel *editingItem;

// Invoked when the user asks to add an item to the list.
@property (nonatomic, strong, readonly) RACAction *addItemAction;

// Removes an item from the grocery list, then invokes `loadItemsAction` upon
// success.
//
// The argument to this command should be a `GCYGroceryItem` representing the
// item to remove.
@property (nonatomic, strong, readonly) RACAction *removeItemAction;

// Removes all crossed off items from the grocery list, then invokes
// `loadItemsAction` upon success.
@property (nonatomic, strong, readonly) RACAction *doneShoppingAction;

@end
