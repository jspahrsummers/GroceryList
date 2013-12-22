//
//  GCYUserController.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import <Foundation/Foundation.h>

// Manages user credentials.
@interface GCYUserController : NSObject

// The signed in client, if any.
@property (atomic, strong, readonly) OCTClient *client;

// Returns the shared user controller.
+ (instancetype)sharedUserController;

// If the user has not yet signed in, opens the default web browser, prompting
// the user to sign in and authorize the app.
//
// If the user has already signed in, attempts to re-authenticate them using the
// saved token, pushing them into the sign in flow if that fails.
//
// Returns a signal that sends an OCTClient then completed when the sign in
// process is finished successfully.
- (RACSignal *)signIn;

@end
