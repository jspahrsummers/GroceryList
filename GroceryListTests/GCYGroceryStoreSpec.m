//
//  GCYGroceryStoreSpec.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-22.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryStore.h"

SpecBegin(GCYGroceryStore)

NSString *blobSHA = @"deadbeef";

__block OCTTreeEntry *entry;
__block GCYGroceryStore *store;

beforeEach(^{
	entry = [OCTTreeEntry modelWithDictionary:@{
		@"path": @"Neighborhood Store",
		@"type": @(OCTTreeEntryTypeBlob),
		@"mode": @(OCTTreeEntryModeFile),
		@"SHA": blobSHA
	} error:NULL];

	store = [GCYGroceryStore modelWithDictionary:@{
		@"name": @"Neighborhood Store",
	} error:NULL];

	expect(entry).notTo.beNil();
	expect(store).notTo.beNil();
});

it(@"should instantiate from a tree entry", ^{
	GCYGroceryStore *createdStore = [[GCYGroceryStore groceryStoreWithTreeEntry:entry] first];
	expect(createdStore).to.equal(store);
});

it(@"should create a tree entry with a given SHA", ^{
	OCTTreeEntry *createdEntry = [[store treeEntryWithBlobSHA:blobSHA] first];
	expect(createdEntry).to.equal(entry);
});

SpecEnd
