//
//  GCYEditableGroceryItemViewModel.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItemViewModel.h"

@interface GCYEditableGroceryItemViewModel : GCYGroceryItemViewModel

// The new name for the item.
@property (nonatomic, copy) NSString *editedName;

// The `GCYGroceryItemStoreViewModel`s that the user should be able to select from for
// this item, in the order that they should be presented.
@property (nonatomic, copy, readonly) NSArray *stores;

// Saves the grocery item to the list.
@property (nonatomic, strong, readonly) RACAction *saveItemAction;

@end
