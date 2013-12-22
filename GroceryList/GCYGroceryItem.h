//
//  GCYGroceryItem.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-05-19.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

@class GCYGroceryStore;

// An item on the grocery list.
@interface GCYGroceryItem : MTLModel

// The name of the item (case insensitive).
@property (nonatomic, copy, readonly) NSString *name;

// The `GCYGroceryStore`s that this item can be found in.
@property (nonatomic, copy, readonly) NSSet *stores;

// Whether this grocery item is in the user's shopping cart.
@property (nonatomic, getter = isInCart, readonly) BOOL inCart;

// Attempts to parse a grocery store file into items.
//
// string - The unparsed lines from a grocery store file.
// store  - The grocery store corresponding to the file.
//
// Returns a signal that will send zero or more `GCYGroceryItem`s then complete.
+ (RACSignal *)groceryItemsWithString:(NSString *)string store:(GCYGroceryStore *)store;

// Converts items into a grocery store file.
//
// items - The `GCYGroceryItem`s to serialize.
//
// Returns a signal that will send the generated `NSString` then complete.
+ (RACSignal *)stringWithGroceryItems:(NSSet *)items;

@end
