//
//  GCYGroceryListViewModel.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryListViewModel.h"
#import "GCYViewModel+Protected.h"

#import "GCYEditableItemViewModel.h"
#import "GCYGroceryItem.h"
#import "GCYGroceryItemViewModel.h"
#import "GCYGroceryList.h"
#import "GCYGroceryStoreViewModel.h"
#import "GCYStoreListViewModel.h"
#import "GCYUserController.h"
#import "RACSignal+GCYOperatorAdditions.h"

#ifndef GCY_LIST_REPOSITORY
#error "Define GCY_LIST_REPOSITORY to the owner/name of the repository to store the grocery list within."
#endif

@interface GCYGroceryListViewModel ()

@property (atomic, strong) OCTRepository *repository;
@property (atomic, strong) GCYGroceryList *list;
@property (atomic, strong) NSArray *allItems;

@end

@implementation GCYGroceryListViewModel

#pragma mark Lifecycle

- (instancetype)init {
	self = [super init];
	if (self == nil) return nil;

	@weakify(self);

	self.store = GCYGroceryStoreViewModel.allStoresViewModel;

	RACSignal *hasClient = [RACObserve(GCYUserController.sharedUserController, client) map:^(OCTClient *client) {
		return @(client != nil);
	}];

	_signInAction = [[RACSignal
		defer:^{
			return [GCYUserController.sharedUserController signIn];
		}]
		actionEnabledIf:[hasClient not]];

	RAC(self, repository) = [[[RACObserve(GCYUserController.sharedUserController, client)
		ignore:nil]
		map:^(OCTClient *client) {
			NSString *repositoryNWO = @(metamacro_stringify(GCY_LIST_REPOSITORY));

			NSArray *pieces = [repositoryNWO componentsSeparatedByString:@"/"];
			NSAssert(pieces.count == 2, @"Repository name should be of the form \"owner/name\", instead got: %@", repositoryNWO);

			return [client fetchRepositoryWithName:pieces[1] owner:pieces[0]];
		}]
		switchToLatest];

	RACAggregatingSignalGenerator *loadListGenerator = [[[[[RACObserve(self, repository)
		ignore:nil]
		take:1]
		flattenMap:^(OCTRepository *repository) {
			return [GCYUserController.sharedUserController.client gcy_groceryListWithRepository:repository];
		}]
		gcy_signalGenerator]
		aggregate];
	
	RAC(self, list) = [[loadListGenerator.generatedSignals
		map:^(RACSignal *signal) {
			return [signal catchTo:[RACSignal empty]];
		}]
		switchToLatest];

	RACAggregatingSignalGenerator *loadItemsGenerator = [[loadListGenerator
		postcompose:[RACDynamicSignalGenerator
			generatorWithBlock:^(GCYGroceryList *list) {
				return [[[list.items.rac_signal
					map:^(GCYGroceryItem *item) {
						return [[GCYGroceryItemViewModel alloc] initWithList:list item:item];
					}]
					collect]
					map:^(NSArray *items) {
						// FIXME: This doesn't belong here.
						return [items sortedArrayUsingComparator:^(GCYGroceryItemViewModel *itemA, GCYGroceryItemViewModel *itemB) {
							return [itemA.item.name localizedCaseInsensitiveCompare:itemB.item.name];
						}];
					}];
			}]]
		aggregate];
	
	RAC(self, allItems) = [[[loadItemsGenerator.generatedSignals
		map:^(RACSignal *signal) {
			return [signal catchTo:[RACSignal empty]];
		}]
		switchToLatest]
		startWith:@[]];
	
	// TODO: Should this be an action?
	[[[[[[RACObserve(self, allItems)
		ignore:nil]
		map:^(NSArray *items) {
			return [items.rac_signal flattenMap:^(GCYGroceryItemViewModel *viewModel) {
				@strongify(self);
				return [[RACObserve(viewModel, inCart)
					skip:1]
					mapReplace:viewModel];
			}];
		}]
		switchToLatest]
		map:^(GCYGroceryItemViewModel *viewModel) {
			@strongify(self);

			NSDictionary *newDict = [viewModel.item.dictionaryValue mtl_dictionaryByAddingEntriesFromDictionary:@{
				@keypath(viewModel.item, inCart): @(viewModel.inCart)
			}];

			NSError *error = nil;
			GCYGroceryItem *newItem = [viewModel.item.class modelWithDictionary:newDict error:&error];
			if (newItem == nil) return [RACSignal error:error];

			return [[GCYUserController.sharedUserController.client
				// TODO: Update the VM's `item` too?
				gcy_replaceItem:viewModel.item withItem:newItem inGroceryList:self.list]
				catch:^(NSError *error) {
					[self->_errors sendNext:error];
					[self.loadItemsAction execute:nil];

					return [RACSignal empty];
				}];
		}]
		concat]
		subscribe:nil];

	RAC(self, items) = [[[[RACObserve(self, allItems)
		deliverOn:RACScheduler.mainThreadScheduler]
		combineLatestWith:RACObserve(self, store)]
		reduceEach:^(NSArray *items, GCYGroceryStoreViewModel *store) {
			if (store == GCYGroceryStoreViewModel.allStoresViewModel) return [RACSignal return:items];

			// TODO: Is there a more efficient way to do this?
			return [[items.rac_signal
				filter:^(GCYGroceryItemViewModel *viewModel) {
					return [viewModel.item.stores containsObject:store.store];
				}]
				collect];
		}]
		switchToLatest];

	_loadItemsAction = [loadItemsGenerator action];

	RACSignal *waitForList = [[RACObserve(self, list)
		ignore:nil]
		take:1];
	
	_switchListsAction = [[waitForList
		map:^(GCYGroceryList *list) {
			return [[GCYStoreListViewModel alloc] initWithGroceryList:list];
		}]
		action];
	
	RACAggregatingSignalGenerator *editItemGenerator = [[RACDynamicSignalGenerator
		generatorWithBlock:^(GCYGroceryItem *item) {
			return [waitForList map:^(GCYGroceryList *list) {
				return [[GCYEditableItemViewModel alloc] initWithList:list item:item];
			}];
		}]
		aggregate];
	
	RAC(self, editingItem) = [[editItemGenerator.generatedSignals
		concat]
		deliverOn:RACScheduler.mainThreadScheduler];
	
	_addItemAction = [[[[RACSignal
		return:nil]
		gcy_signalGenerator]
		postcompose:editItemGenerator]
		action];

	_removeItemAction = [[RACDynamicSignalGenerator
		generatorWithBlock:^(GCYGroceryItem *item) {
			@strongify(self);
			return [[waitForList
				flattenMap:^(GCYGroceryList *list) {
					return [GCYUserController.sharedUserController.client gcy_removeItem:item inGroceryList:list];
				}]
				concat:[self.loadItemsAction deferred:nil]];
		}]
		action];
	
	RACSignal *anyItemsCrossedOff = [[[RACObserve(self, items)
		ignore:nil]
		map:^(NSArray *items) {
			NSArray *inCartSignals = [[[items.rac_signal
				map:^(GCYGroceryItemViewModel *viewModel) {
					@strongify(self);
					return RACObserve(viewModel, inCart);
				}]
				startWith:[RACSignal return:@NO]]
				array];

			return [[RACSignal combineLatest:inCartSignals] or];
		}]
		switchToLatest];
	
	_doneShoppingAction = [[[[[[[[[RACObserve(self, items)
		ignore:nil]
		take:1]
		flattenMap:^(NSArray *items) {
			return items.rac_signal;
		}]
		filter:^(GCYGroceryItemViewModel *viewModel) {
			return viewModel.inCart;
		}]
		map:^(GCYGroceryItemViewModel *viewModel) {
			return viewModel.item;
		}]
		map:^(GCYGroceryItem *item) {
			@strongify(self);

			// TODO: Coalesce all removals into one request.
			return [GCYUserController.sharedUserController.client gcy_removeItem:item inGroceryList:self.list];
		}]
		concat]
		concat:[self.loadItemsAction deferred:nil]]
		actionEnabledIf:anyItemsCrossedOff];
	
	[[RACSignal
		merge:@[
			self.signInAction.errors,
			self.loadItemsAction.errors,
			self.addItemAction.errors,
			self.removeItemAction.errors,
			self.doneShoppingAction.errors,
		]]
		subscribe:_errors];
	
	[[[[self.didBecomeActiveSignal
		flattenMap:^(GCYGroceryListViewModel *viewModel) {
			return [[[[viewModel.signInAction
				deferred:nil]
				ignoreValues]
				concat:[RACSignal return:viewModel]]
				catchTo:[RACSignal empty]];
		}]
		flattenMap:^(GCYGroceryListViewModel *viewModel) {
			return [[[viewModel.loadItemsAction
				deferred:nil]
				concat:[RACSignal return:RACUnit.defaultUnit]]
				catchTo:[RACSignal empty]];
		}]
		take:1]
		subscribe:nil];

	return self;
}

@end
