//
//  GCYGroceryItemViewModel.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItemViewModel.h"
#import "GCYGroceryItem.h"
#import "GCYGroceryList.h"

@implementation GCYGroceryItemViewModel

- (instancetype)initWithList:(GCYGroceryList *)list item:(GCYGroceryItem *)item {
	NSCParameterAssert(list != nil);

	self = [super init];
	if (self == nil) return nil;

	_list = list;
	_item = item;
	_inCart = item.inCart;

	return self;
}

@end
