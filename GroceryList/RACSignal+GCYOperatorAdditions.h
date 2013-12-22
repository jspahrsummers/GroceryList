//
//  RACSignal+GCYOperatorAdditions.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-13.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

@interface RACSignal (GCYOperatorAdditions)

// Collects the elements of the receiver into an `NSSet`.
- (RACSignal *)gcy_collectSet;

// Creates a constant signal generator using the receiver.
- (RACSignalGenerator *)gcy_signalGenerator;

@end
