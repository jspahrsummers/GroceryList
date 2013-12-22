//
//  GCYGroceryStoreViewModel.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryStoreViewModel.h"
#import "GCYGroceryStore.h"

@implementation GCYGroceryStoreViewModel

+ (instancetype)allStoresViewModel {
	static id singleton;
	static dispatch_once_t pred;

	dispatch_once(&pred, ^{
		singleton = [[self alloc] initWithStore:nil];
	});

	return singleton;
}

- (instancetype)initWithStore:(GCYGroceryStore *)store {
	self = [super init];
	if (self == nil) return nil;

	_store = store;

	if (self.store == nil) {
		_displayName = NSLocalizedString(@"All Stores", nil);
	} else {
		RAC(self, displayName) = RACObserve(self.store, name);
	}

	return self;
}

@end
