//
//  GCYGroceryStoreListViewModel.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewModel.h"

@class GCYGroceryList;

@interface GCYGroceryStoreListViewModel : GCYViewModel

// A list of `GCYGroceryStoreViewModel`s, in the order they should be presented
// to the user.
@property (nonatomic, copy, readonly) NSArray *stores;

- (instancetype)initWithGroceryList:(GCYGroceryList *)list;

@end
