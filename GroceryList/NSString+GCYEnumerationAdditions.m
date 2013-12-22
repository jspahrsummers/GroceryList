//
//  NSString+GCYEnumerationAdditions.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-08.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "NSString+GCYEnumerationAdditions.h"

@implementation NSString (GCYEnumerationAdditions)

- (RACSignal *)gcy_lineSignal {
	return [RACSignal create:^(id<RACSubscriber> subscriber) {
		[self enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
			[subscriber sendNext:line];
			*stop = subscriber.disposable.disposed;
		}];

		[subscriber sendCompleted];
	}];
}

@end
