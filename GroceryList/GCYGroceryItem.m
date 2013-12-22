//
//  GCYGroceryItem.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-05-19.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItem.h"

#import "GCYGroceryStore.h"
#import "NSString+GCYEnumerationAdditions.h"

@implementation GCYGroceryItem

#pragma mark Parsing

+ (RACSignal *)groceryItemsWithString:(NSString *)string store:(GCYGroceryStore *)store {
	NSParameterAssert(string != nil);
	NSParameterAssert(store != nil);

	return [[string.gcy_lineSignal
		filter:^ BOOL (NSString *line) {
			return line.length > 0;
		}]
		tryMap:^ GCYGroceryItem * (NSString *line, NSError **error) {
			NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"~(.+)~" options:0 error:error];
			if (regex == nil) return nil;

			NSSet *stores = [NSSet setWithObject:store];

			NSTextCheckingResult *match = [regex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
			if (match == nil) {
				return [self modelWithDictionary:@{
					@keypath(GCYGroceryItem.new, name): line,
					@keypath(GCYGroceryItem.new, stores): stores,
					@keypath(GCYGroceryItem.new, inCart): @NO,
				} error:error];
			} else {
				return [self modelWithDictionary:@{
					@keypath(GCYGroceryItem.new, name): [line substringWithRange:[match rangeAtIndex:1]],
					@keypath(GCYGroceryItem.new, stores): stores,
					@keypath(GCYGroceryItem.new, inCart): @YES,
				} error:error];
			}
		}];
}

+ (RACSignal *)stringWithGroceryItems:(NSSet *)items {
	NSParameterAssert(items != nil);

	return [[[[items.rac_signal
		map:^(GCYGroceryItem *item) {
			NSString *line = item.name;
			if (item.inCart) {
				line = [NSString stringWithFormat:@"~%@~", line];
			}

			return line;
		}]
		collect]
		map:^(NSArray *names) {
			return [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		}]
		map:^(NSArray *lines) {
			return [lines componentsJoinedByString:@"\n"];
		}];
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.name.hash;
}

- (BOOL)isEqual:(GCYGroceryItem *)item {
	if (self == item) return YES;
	if (![item isKindOfClass:GCYGroceryItem.class]) return NO;

	return [self.name caseInsensitiveCompare:item.name] == NSOrderedSame;
}

@end
