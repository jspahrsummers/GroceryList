//
//  RACSignal+GCYBackgroundTaskAdditions.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-15.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "RACSignal+GCYBackgroundTaskAdditions.h"

@implementation RACSignal (GCYBackgroundTaskAdditions)

- (RACSignal *)gcy_addBackgroundTask {
	return [[RACSignal
		create:^(id<RACSubscriber> subscriber) {
			UIBackgroundTaskIdentifier identifier = [UIApplication.sharedApplication beginBackgroundTaskWithName:self.name expirationHandler:^{
				[subscriber sendError:[NSError errorWithDomain:RACSignalErrorDomain code:RACSignalErrorTimedOut userInfo:@{
					NSLocalizedDescriptionKey: NSLocalizedString(@"Timed out", nil),
					NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The background task expired before it could complete.", nil),
				}]];
			}];

			if (identifier != UIBackgroundTaskInvalid) {
				[subscriber.disposable addDisposable:[RACDisposable disposableWithBlock:^{
					[UIApplication.sharedApplication endBackgroundTask:identifier];
				}]];
			}

			[self subscribe:subscriber];
		}]
		setNameWithFormat:@"[%@] -gcy_addBackgroundTask", self.name];
}

@end
