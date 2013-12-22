//
//  GCYGroceryList.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-08.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryList.h"

#import "GCYGroceryItem.h"
#import "GCYGroceryStore.h"
#import "NSString+GCYEnumerationAdditions.h"
#import "RACSignal+GCYBackgroundTaskAdditions.h"
#import "RACSignal+GCYOperatorAdditions.h"

// The git reference to fetch and update.
// FIXME: Configurable ref?
static NSString * const GCYGroceryListGitReference = @"heads/master";

@implementation GCYGroceryList
@end

@implementation OCTClient (GCYGroceryListAdditions)

- (RACSignal *)gcy_groceryItemsForTreeEntry:(OCTTreeEntry *)entry inRepository:(OCTRepository *)repository {
	NSParameterAssert(entry != nil);
	NSParameterAssert(repository != nil);

	return [[[[[self
		fetchBlob:entry.SHA inRepository:repository]
		tryMap:^(NSData *blob, NSError **error) {
			return [[NSString alloc] initWithData:blob encoding:NSUTF8StringEncoding];
		}]
		zipWith:[GCYGroceryStore groceryStoreWithTreeEntry:entry]]
		reduceEach:^(NSString *contents, GCYGroceryStore *store) {
			return [GCYGroceryItem groceryItemsWithString:contents store:store];
		}]
		flatten];
}

- (RACSignal *)gcy_createBlobWithGroceryItems:(NSSet *)items inRepository:(OCTRepository *)repository {
	NSParameterAssert(items != nil);
	NSParameterAssert(repository != nil);

	return [[GCYGroceryItem
		stringWithGroceryItems:items]
		flattenMap:^(NSString *string) {
			return [self createBlobWithString:string inRepository:repository];
		}];
}

- (RACSignal *)gcy_groceryItemsWithTree:(OCTTree *)tree inRepository:(OCTRepository *)repository {
	NSParameterAssert(tree != nil);
	NSParameterAssert(repository != nil);

	return [[tree.entries.rac_signal
		flattenMap:^(OCTTreeEntry *entry) {
			return [self gcy_groceryItemsForTreeEntry:entry inRepository:repository];
		}]
		aggregateWithStart:[NSMutableSet set] reduce:^(NSMutableSet *items, GCYGroceryItem *item) {
			// TODO: Use an array for faster replacement of existing items.
			GCYGroceryItem *existingItem = [items member:item];
			if (existingItem == nil) {
				[items addObject:item];
				return items;
			}

			GCYGroceryItem *combinedItem = [GCYGroceryItem modelWithDictionary:@{
				@keypath(combinedItem.name): existingItem.name,
				@keypath(combinedItem.stores): [existingItem.stores setByAddingObjectsFromSet:item.stores],
				@keypath(combinedItem.inCart): @(existingItem.inCart || item.inCart),
			} error:NULL];

			[items removeObject:existingItem];
			[items addObject:combinedItem];
			return items;
		}];
}

- (RACSignal *)gcy_groceryStoresWithTree:(OCTTree *)tree inRepository:(OCTRepository *)repository {
	NSParameterAssert(tree != nil);
	NSParameterAssert(repository != nil);

	return [[tree.entries.rac_signal
		flattenMap:^(OCTTreeEntry *entry) {
			return [GCYGroceryStore groceryStoreWithTreeEntry:entry];
		}]
		gcy_collectSet];
}

- (RACSignal *)gcy_groceryListWithRepository:(OCTRepository *)repository {
	NSParameterAssert(repository != nil);

	return [[[self
		fetchTreeForReference:nil inRepository:repository recursive:YES]
		flattenMap:^(OCTTree *tree) {
			return [RACSignal zip:@[
				[self gcy_groceryItemsWithTree:tree inRepository:repository],
				[self gcy_groceryStoresWithTree:tree inRepository:repository],
			]];
		}]
		tryMap:^(RACTuple *itemsAndStores, NSError **error) {
			RACTupleUnpack(NSSet *items, NSSet *stores) = itemsAndStores;

			return [GCYGroceryList modelWithDictionary:@{
				@keypath(GCYGroceryList.new, repository): repository,
				@keypath(GCYGroceryList.new, items): items ?: [NSSet set],
				@keypath(GCYGroceryList.new, stores): stores ?: [NSSet set],
			} error:error];
		}];
}

- (RACSignal *)gcy_updateItemsForTreeEntry:(OCTTreeEntry *)entry inRepository:(OCTRepository *)repository usingBlock:(NSSet * (^)(NSSet *items))block {
	NSParameterAssert(entry != nil);
	NSParameterAssert(repository != nil);
	NSParameterAssert(block != nil);

	return [[[[[self
		gcy_groceryItemsForTreeEntry:entry inRepository:repository]
		gcy_collectSet]
		map:^(NSSet *items) {
			// TODO: Bail out of unnecessary work if the resulting set is the same.
			return block(items);
		}]
		flattenMap:^(NSSet *items) {
			return [self gcy_createBlobWithGroceryItems:items inRepository:repository];
		}]
		tryMap:^(NSString *blobSHA, NSError **error) {
			NSDictionary *newEntryDict = [entry.dictionaryValue mtl_dictionaryByAddingEntriesFromDictionary:@{
				@keypath(entry.SHA): blobSHA
			}];

			return [entry.class modelWithDictionary:newEntryDict error:error];
		}];
}

- (RACSignal *)gcy_treeEntriesByAddingItem:(GCYGroceryItem *)item toTreeEntries:(NSArray *)entries repository:(OCTRepository *)repository {
	NSParameterAssert(item != nil);
	NSParameterAssert(entries != nil);
	NSParameterAssert(repository != nil);

	return [[item.stores.rac_signal
		flattenMap:^(GCYGroceryStore *storeToAdd) {
			RACSignal *newTreeEntry = [[self
				gcy_createBlobWithGroceryItems:[NSSet setWithObject:item] inRepository:repository]
				flattenMap:^(NSString *blobSHA) {
					return [storeToAdd treeEntryWithBlobSHA:blobSHA];
				}];

			return [[[[entries.rac_signal
				flattenMap:^(OCTTreeEntry *entry) {
					return [[[GCYGroceryStore
						groceryStoreWithTreeEntry:entry]
						filter:^(GCYGroceryStore *existingStore) {
							return [existingStore isEqual:storeToAdd];
						}]
						mapReplace:entry];
				}]
				flattenMap:^(OCTTreeEntry *entry) {
					return [self gcy_updateItemsForTreeEntry:entry inRepository:repository usingBlock:^(NSSet *items) {
						return [items setByAddingObject:item];
					}];
				}]
				concat:newTreeEntry]
				take:1];
		}]
		collect];
}

- (RACSignal *)gcy_treeEntriesByRemovingItem:(GCYGroceryItem *)item fromTreeEntries:(NSArray *)entries repository:(OCTRepository *)repository {
	NSParameterAssert(item != nil);
	NSParameterAssert(entries != nil);
	NSParameterAssert(repository != nil);

	return [[item.stores.rac_signal
		flattenMap:^(GCYGroceryStore *storeToDelete) {
			return [[[entries.rac_signal
				flattenMap:^(OCTTreeEntry *entry) {
					return [[[GCYGroceryStore
						groceryStoreWithTreeEntry:entry]
						filter:^(GCYGroceryStore *existingStore) {
							return [existingStore isEqual:storeToDelete];
						}]
						mapReplace:entry];
				}]
				flattenMap:^(OCTTreeEntry *entry) {
					return [self gcy_updateItemsForTreeEntry:entry inRepository:repository usingBlock:^(NSSet *items) {
						NSMutableSet *mutableItems = [items mutableCopy];
						[mutableItems removeObject:item];

						return mutableItems;
					}];
				}]
				take:1];
		}]
		collect];
}

- (RACSignal *)gcy_updateGroceryList:(GCYGroceryList *)list withMessage:(NSString *)message usingGenerator:(RACSignalGenerator *)generator {
	NSParameterAssert(list != nil);
	NSParameterAssert(message != nil);
	NSParameterAssert(generator != nil);

	return [[[[[[self
		fetchReference:GCYGroceryListGitReference inRepository:list.repository]
		flattenMap:^(OCTRef *ref) {
			return [self fetchCommit:ref.SHA inRepository:list.repository];
		}]
		flattenMap:^(OCTCommit *commit) {
			return [[[self
				fetchTreeForReference:commit.SHA inRepository:list.repository recursive:YES]
				flattenMap:^(OCTTree *tree) {
					return [generator signalWithValue:tree];
				}]
				flattenMap:^(OCTTree *newTree) {
					return [self createCommitWithMessage:message inRepository:list.repository pointingToTreeWithSHA:newTree.SHA parentCommitSHAs:@[ commit.SHA ]];
				}];
		}]
		flattenMap:^(OCTCommit *newCommit) {
			return [self updateReference:GCYGroceryListGitReference inRepository:list.repository toSHA:newCommit.SHA force:NO];
		}]
		ignoreValues]
		gcy_addBackgroundTask];
}

- (RACSignal *)gcy_descriptionForStores:(NSSet *)stores {
	return [stores.rac_signal aggregateWithStart:[NSMutableString string] reduce:^(NSMutableString *accumulated, GCYGroceryStore *store) {
		if (accumulated.length > 0) {
			[accumulated appendString:@", "];
		}

		[accumulated appendString:store.name];
		return accumulated;
	}];
}

- (RACSignal *)gcy_addItem:(GCYGroceryItem *)item inGroceryList:(GCYGroceryList *)list {
	NSParameterAssert(item != nil);
	NSParameterAssert(list != nil);

	RACSignalGenerator *generator = [RACDynamicSignalGenerator generatorWithBlock:^(OCTTree *tree) {
		return [[self
			gcy_treeEntriesByAddingItem:item toTreeEntries:tree.entries repository:list.repository]
			flattenMap:^(NSArray *newEntries) {
				return [self createTreeWithEntries:newEntries inRepository:list.repository basedOnTreeWithSHA:tree.SHA];
			}];
	}];

	NSString *storesDescription = [[self gcy_descriptionForStores:item.stores] first];
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Added \"%@\" to %@", nil), item.name, storesDescription];

	return [self gcy_updateGroceryList:list withMessage:message usingGenerator:generator];
}

- (RACSignal *)gcy_removeItem:(GCYGroceryItem *)item inGroceryList:(GCYGroceryList *)list {
	NSParameterAssert(item != nil);
	NSParameterAssert(list != nil);

	RACSignalGenerator *generator = [RACDynamicSignalGenerator generatorWithBlock:^(OCTTree *tree) {
		return [[self
			gcy_treeEntriesByRemovingItem:item fromTreeEntries:tree.entries repository:list.repository]
			flattenMap:^(NSArray *newEntries) {
				return [self createTreeWithEntries:newEntries inRepository:list.repository basedOnTreeWithSHA:tree.SHA];
			}];
	}];

	NSString *storesDescription = [[self gcy_descriptionForStores:item.stores] first];
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Removed \"%@\" from %@", nil), item.name, storesDescription];

	return [self gcy_updateGroceryList:list withMessage:message usingGenerator:generator];
}

- (RACSignal *)gcy_replaceItem:(GCYGroceryItem *)oldItem withItem:(GCYGroceryItem *)newItem inGroceryList:(GCYGroceryList *)list {
	NSParameterAssert(oldItem != nil);
	NSParameterAssert(newItem != nil);
	NSParameterAssert(list != nil);

	RACSignalGenerator *generator = [RACDynamicSignalGenerator generatorWithBlock:^(OCTTree *tree) {
		return [[[self
			gcy_treeEntriesByRemovingItem:oldItem fromTreeEntries:tree.entries repository:list.repository]
			flattenMap:^(NSArray *entries) {
				return [self gcy_treeEntriesByAddingItem:newItem toTreeEntries:entries repository:list.repository];
			}]
			flattenMap:^(NSArray *entries) {
				return [self createTreeWithEntries:entries inRepository:list.repository basedOnTreeWithSHA:tree.SHA];
			}];
	}];

	NSString *message;
	if ([oldItem.name caseInsensitiveCompare:newItem.name] == NSOrderedSame) {
		message = [NSString stringWithFormat:NSLocalizedString(@"Updated \"%@\"", nil), newItem.name];
	} else {
		message = [NSString stringWithFormat:NSLocalizedString(@"Renamed \"%@\" to \"%@\"", nil), oldItem.name, newItem.name];
	}

	return [self gcy_updateGroceryList:list withMessage:message usingGenerator:generator];
}

@end
