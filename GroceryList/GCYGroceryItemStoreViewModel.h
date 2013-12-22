//
//  GCYGroceryItemStoreViewModel.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewModel.h"

@class GCYGroceryStore;

// Allows the user to select a store that the item may or may not be bought at.
@interface GCYGroceryItemStoreViewModel : GCYViewModel

@property (nonatomic, strong, readonly) GCYGroceryStore *store;

// Whether the user has indicated that the item can be found in this store.
@property (nonatomic, assign, getter = isSelected) BOOL selected;

- (instancetype)initWithStore:(GCYGroceryStore *)store;

@end
