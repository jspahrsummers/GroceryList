//
//  GCYGroceryItemStoreViewModel.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItemStoreViewModel.h"

@implementation GCYGroceryItemStoreViewModel

#pragma mark Lifecycle

- (instancetype)initWithStore:(GCYGroceryStore *)store {
	NSParameterAssert(store != nil);

	self = [super init];
	if (self == nil) return nil;

	_store = store;

	return self;
}

@end
