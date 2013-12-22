//
//  GCYViewModel.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-11.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewModel.h"
#import "GCYViewModel+Protected.h"

@implementation GCYViewModel

- (id)init {
	self = [super init];
	if (self == nil) return nil;

	_errors = [[RACSubject subject] setNameWithFormat:@"%@ -errors", self];

	return self;
}

- (void)dealloc {
	[_errors sendCompleted];
}

@end
