//
//  GCYGroceryStoreListViewModel.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryStoreListViewModel.h"

#import "GCYGroceryList.h"
#import "GCYGroceryStore.h"
#import "GCYGroceryStoreViewModel.h"

@implementation GCYGroceryStoreListViewModel

- (instancetype)initWithGroceryList:(GCYGroceryList *)list {
	self = [super init];
	if (self == nil) return nil;

	RAC(self, stores) = [[[[[list.stores.rac_signal
		map:^(GCYGroceryStore *store) {
			return [[GCYGroceryStoreViewModel alloc] initWithStore:store];
		}]
		startWith:GCYGroceryStoreViewModel.allStoresViewModel]
		collect]
		map:^(NSArray *stores) {
			// TODO: Share with the editable item VM somehow?
			return [stores sortedArrayUsingComparator:^(GCYGroceryStoreViewModel *storeA, GCYGroceryStoreViewModel *storeB) {
				return [storeA.displayName localizedCaseInsensitiveCompare:storeB.displayName];
			}];
		}]
		deliverOn:RACScheduler.mainThreadScheduler];

	return self;
}

@end
