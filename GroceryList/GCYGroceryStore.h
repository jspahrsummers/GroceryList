//
//  GCYGroceryStore.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-08.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

// A store at which grocery items can be found.
@interface GCYGroceryStore : MTLModel

// The name of the store (case insensitive).
@property (nonatomic, copy, readonly) NSString *name;

// Instantiates a `GCYGroceryStore` based on a tree entry in a repository.
//
// TODO: Put this into a category on OCTTreeEntry instead.
+ (RACSignal *)groceryStoreWithTreeEntry:(OCTTreeEntry *)entry;

// Builds a tree entry with a grocery store and a SHA that points to the desired
// content.
- (RACSignal *)treeEntryWithBlobSHA:(NSString *)blobSHA;

@end
