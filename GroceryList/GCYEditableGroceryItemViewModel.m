//
//  GCYEditableGroceryItemViewModel.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYEditableGroceryItemViewModel.h"
#import "GCYViewModel+Protected.h"

#import "GCYGroceryItem.h"
#import "GCYGroceryList.h"
#import "GCYGroceryStore.h"
#import "GCYGroceryItemStoreViewModel.h"
#import "GCYUserController.h"
#import "RACSignal+GCYOperatorAdditions.h"

static NSString * const GCYEditableGroceryItemViewModelErrorDomain = @"GCYEditableGroceryItemViewModelErrorDomain";

static const NSInteger GCYEditableGroceryItemViewModelNoStoresSelectedError = 1;

@implementation GCYEditableGroceryItemViewModel

- (instancetype)initWithList:(GCYGroceryList *)list item:(GCYGroceryItem *)item {
	self = [super initWithList:list item:item];
	if (self == nil) return nil;

	@weakify(self);
	
	RAC(self, stores) = [[[[list.stores.rac_signal
		map:^(GCYGroceryStore *store) {
			return [[GCYGroceryItemStoreViewModel alloc] initWithStore:store];
		}]
		collect]
		map:^(NSArray *stores) {
			// FIXME: This doesn't belong here.
			return [stores sortedArrayUsingComparator:^(GCYGroceryItemStoreViewModel *storeA, GCYGroceryItemStoreViewModel *storeB) {
				return [storeA.store.name localizedCaseInsensitiveCompare:storeB.store.name];
			}];
		}]
		deliverOn:RACScheduler.mainThreadScheduler];

	RACSignal *selectedStores = [[[[[[RACObserve(self, stores)
		take:1]
		flattenMap:^(NSArray *stores) {
			return stores.rac_signal;
		}]
		filter:^(GCYGroceryItemStoreViewModel *store) {
			return store.selected;
		}]
		map:^(GCYGroceryItemStoreViewModel *viewModel) {
			return viewModel.store;
		}]
		gcy_collectSet]
		try:^(NSSet *stores, NSError **error) {
			if (stores.count == 0) {
				if (error != NULL) {
					*error = [NSError errorWithDomain:GCYEditableGroceryItemViewModelErrorDomain code:GCYEditableGroceryItemViewModelNoStoresSelectedError userInfo:@{
						NSLocalizedDescriptionKey: NSLocalizedString(@"No Stores Selected", nil),
						NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Select the grocery stores this item can be found in.", nil),
					}];
				}

				return NO;
			}

			return YES;
		}];

	RACSignal *newItem = [selectedStores tryMap:^(NSSet *stores, NSError **error) {
		@strongify(self);

		GCYGroceryItem *item = [GCYGroceryItem modelWithDictionary:@{
			@keypath(item.name): self.editedName,
			@keypath(item.stores): stores,
			@keypath(item.inCart): @NO,
		} error:error];

		return item;
	}];

	RACSignal *updatedItem = [selectedStores tryMap:^(NSSet *stores, NSError **error) {
		@strongify(self);

		NSDictionary *newItemDict = [item.dictionaryValue mtl_dictionaryByAddingEntriesFromDictionary:@{
			@keypath(item.name): self.editedName ?: item.name,
			@keypath(item.stores): stores,
		}];

		return [GCYGroceryItem modelWithDictionary:newItemDict error:error];
	}];

	_saveItemAction = [[[RACSignal
		if:[RACSignal return:@(item != nil)]
			then:updatedItem
			else:newItem]
		flattenMap:^(GCYGroceryItem *item) {
			// TODO: Properly handle edits.
			return [GCYUserController.sharedUserController.client gcy_addItem:item inGroceryList:list];
		}]
		actionEnabledIf:[RACObserve(self, editedName)
			map:^(NSString *name) {
				return @(name.length > 0);
			}]];
	
	[self.saveItemAction.errors subscribe:_errors];
	return self;
}

@end
