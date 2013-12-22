//
//  GCYGroceryStoreViewModel.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewModel.h"

@class GCYGroceryStore;

@interface GCYGroceryStoreViewModel : GCYViewModel

@property (nonatomic, strong, readonly) GCYGroceryStore *store;

// The name of the store, as it should be displayed to the user.
@property (nonatomic, copy, readonly) NSString *displayName;

// The view model representing all stores at once.
+ (instancetype)allStoresViewModel;

- (instancetype)initWithStore:(GCYGroceryStore *)store;

@end
