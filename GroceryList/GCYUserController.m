//
//  GCYUserController.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYUserController.h"

@interface GCYUserController ()

@property (atomic, strong, readwrite) OCTClient *client;

@end

@implementation GCYUserController

#pragma mark Lifecycle

+ (instancetype)sharedUserController {
	static dispatch_once_t pred;
	static id singleton;

	dispatch_once(&pred, ^{
		singleton = [[self alloc] init];

		NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:(__bridge id)kCFBundleVersionKey];
		OCTClient.userAgent = [NSString stringWithFormat:@"grocery-list-ios/%@", version];

		[OCTClient setClientID:@"8b91269afcdcb700bcab" clientSecret:@"f93f6ed64ca7059812061748bccb4a5ebd50b1f7"];
	});

	return singleton;
}

#pragma mark Authentication

- (RACSignal *)signIn {
	RACSignal *signIn = [RACSignal defer:^{
		return [[OCTClient
			signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepository | OCTClientAuthorizationScopesUser]
			flattenMap:^(OCTClient *client) {
				return [[[self
					saveToken:client.token forUser:client.user]
					ignoreValues]
					concat:[RACSignal return:client]];
			}];
	}];

	return [[[[[self
		authenticatedClientWithSavedCredentials]
		catch:^(NSError *error) {
			NSLog(@"Could not log in automatically: %@", error);
			return [RACSignal empty];
		}]
		concat:signIn]
		take:1]
		doNext:^(OCTClient *client) {
			self.client = client;
		}];
}

#pragma mark Saved credentials

- (RACSignal *)authenticatedClientWithSavedCredentials {
	return [RACSignal defer:^{
		NSURLCredential *credential = [NSURLCredentialStorage.sharedCredentialStorage defaultCredentialForProtectionSpace:self.protectionSpace];
		if (credential == nil || !credential.hasPassword) return [RACSignal empty];

		OCTUser *user = [OCTUser userWithLogin:credential.user server:OCTServer.dotComServer];
		return [RACSignal return:[OCTClient authenticatedClientWithUser:user token:credential.password]];
	}];
}

- (RACSignal *)saveToken:(NSString *)token forUser:(OCTUser *)user {
	NSParameterAssert(token != nil);
	NSParameterAssert(user != nil);

	return [RACSignal create:^(id<RACSubscriber> subscriber) {
		NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:user.login password:token persistence:NSURLCredentialPersistenceSynchronizable];
		[NSURLCredentialStorage.sharedCredentialStorage setDefaultCredential:credential forProtectionSpace:self.protectionSpace];

		[subscriber sendCompleted];
	}];
}

- (NSURLProtectionSpace *)protectionSpace {
	return [[NSURLProtectionSpace alloc] initWithHost:@"github.com" port:80 protocol:NSURLProtectionSpaceHTTPS realm:nil authenticationMethod:nil];
}

@end
