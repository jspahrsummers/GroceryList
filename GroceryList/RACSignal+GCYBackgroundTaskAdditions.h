//
//  RACSignal+GCYBackgroundTaskAdditions.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-15.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

@interface RACSignal (GCYBackgroundTaskAdditions)

// Begins a long-running background task before subscribing to the receiver,
// then automatically ends the task when the signal terminates.
//
// If running in the background is not possible, the signal will proceed
// normally, but will not continue executing while the app is backgrounded.
//
// Returns a signal which forwards all of the receiver's events. If the
// background task expires before the signal terminates normally, an error with
// code `RACSignalErrorTimedOut` will be sent.
- (RACSignal *)gcy_addBackgroundTask;

@end
