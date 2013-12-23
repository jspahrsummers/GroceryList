//
//  GCYGroceryItemSpec.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItem.h"
#import "GCYGroceryStore.h"

SpecBegin(GCYGroceryItem)

__block GCYGroceryStore *store;

__block NSString *list;
__block NSSet *items;

beforeEach(^{
	store = [GCYGroceryStore modelWithDictionary:@{
		@"name": @"Friendly Neighborhood Grocery Store",
	} error:NULL];

	list = @"~Crackers~\nBread\nPeanut butter";
	items = [NSSet setWithArray:@[
		[GCYGroceryItem modelWithDictionary:@{
			@"name": @"Bread",
			@"stores": [NSSet setWithObject:store],
			@"inCart": @NO
		} error:NULL],

		[GCYGroceryItem modelWithDictionary:@{
			@"name": @"Crackers",
			@"stores": [NSSet setWithObject:store],
			@"inCart": @YES
		} error:NULL],

		[GCYGroceryItem modelWithDictionary:@{
			@"name": @"Peanut butter",
			@"stores": [NSSet setWithObject:store],
			@"inCart": @NO
		} error:NULL],
	]];
});

it(@"should parse a list of items", ^{
	// Verify that a trailing newline doesn't affect the list contents.
	list = [list stringByAppendingString:@"\n"];

	NSArray *parsedItems = [[GCYGroceryItem groceryItemsWithString:list store:store] array];
	expect(parsedItems).notTo.beNil();
	expect([NSSet setWithArray:parsedItems]).to.equal(items);
});

it(@"should serialize items into a list", ^{
	NSString *serializedList = [[GCYGroceryItem stringWithGroceryItems:items] first];
	expect(serializedList).to.equal(list);
});

SpecEnd
