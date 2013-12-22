//
//  GCYGroceryList.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-08.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItem.h"

// A grocery list, corresponding to one repository.
@interface GCYGroceryList : MTLModel

// The repository containing the grocery items.
@property (nonatomic, strong, readonly) OCTRepository *repository;

// All of the `GCYGroceryItem`s in this list, for all stores.
@property (nonatomic, copy, readonly) NSSet *items;

// All of the `GCYGroceryStore`s available in this list.
@property (nonatomic, copy, readonly) NSSet *stores;

@end

@interface OCTClient (GCYGroceryListAdditions)

// Fetches the grocery list for the given repository.
//
// Returns a signal that will send a `GCYGroceryList` then complete.
- (RACSignal *)gcy_groceryListWithRepository:(OCTRepository *)repository;

// Adds a grocery item to the given list, or adds it to more stores.
//
// item - The item to add to `item.stores`.
// list - The grocery list to add the item to.
//
// Returns a signal that will complete upon success.
- (RACSignal *)gcy_addItem:(GCYGroceryItem *)item inGroceryList:(GCYGroceryList *)list;

// Removes a grocery item from its stores.
//
// If the item is removed from all stores, it will be removed from the whole
// list.
//
// item - The item to remove from `item.stores`.
// list - The grocery list to add the item to.
//
// Returns a signal that will complete upon success.
- (RACSignal *)gcy_removeItem:(GCYGroceryItem *)item inGroceryList:(GCYGroceryList *)list;

// Removes `oldItem` from its stores, and adds `newItem` to its stores.
//
// This can be used to effectively update `oldItem` to the properties of
// `newItem`.
//
// oldItem - The item to remove from `oldItem.stores`.
// newItem - The item to add to `newItem.stores`.
// list    - The grocery list to perform the replacement within.
//
// Returns a signal that will complete upon success.
- (RACSignal *)gcy_replaceItem:(GCYGroceryItem *)oldItem withItem:(GCYGroceryItem *)newItem inGroceryList:(GCYGroceryList *)list;

@end
