//
//  GCYGroceryStore.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-08.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryStore.h"

@implementation GCYGroceryStore

#pragma mark Lifecycle

+ (RACSignal *)groceryStoreWithTreeEntry:(OCTTreeEntry *)entry {
	NSParameterAssert(entry != nil);

	return [RACSignal defer:^{
		NSError *error = nil;
		GCYGroceryStore *store = [GCYGroceryStore modelWithDictionary:@{
			@keypath(store.name): entry.path,
		} error:&error];
		
		if (store == nil) {
			return [RACSignal error:error];
		} else {
			return [RACSignal return:store];
		}
	}];
}

- (RACSignal *)treeEntryWithBlobSHA:(NSString *)blobSHA {
	NSParameterAssert(blobSHA != nil);

	return [RACSignal defer:^{
		NSError *error = nil;
		OCTTreeEntry *entry = [OCTTreeEntry modelWithDictionary:@{
			@keypath(entry.SHA): blobSHA,
			@keypath(entry.path): self.name,
			@keypath(entry.type): @(OCTTreeEntryTypeBlob),
			@keypath(entry.mode): @(OCTTreeEntryModeFile),
		} error:&error];
		
		if (entry == nil) {
			return [RACSignal error:error];
		} else {
			return [RACSignal return:entry];
		}
	}];
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.name.lowercaseString.hash;
}

- (BOOL)isEqual:(GCYGroceryStore *)store {
	if (self == store) return YES;
	if (![store isKindOfClass:GCYGroceryStore.class]) return NO;

	return [self.name caseInsensitiveCompare:store.name] == NSOrderedSame;
}

@end
