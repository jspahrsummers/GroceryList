//
//  RACSignal+GCYOperatorAdditions.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-13.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "RACSignal+GCYOperatorAdditions.h"

@implementation RACSignal (GCYOperatorAdditions)

- (RACSignal *)gcy_collectSet {
	return [[self
		aggregateWithStart:[NSSet set] reduce:^(NSSet *accumulated, id value) {
			return [accumulated setByAddingObject:value ?: NSNull.null];
		}]
		setNameWithFormat:@"[%@] -gcy_collectSet", self.name];
}

- (RACSignalGenerator *)gcy_signalGenerator {
	return [RACDynamicSignalGenerator generatorWithBlock:^(id _) {
		return self;
	}];
}

@end
