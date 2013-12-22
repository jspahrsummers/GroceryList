//
//  GCYAppDelegate.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-04-09.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYAppDelegate.h"
#import "GCYGroceryListViewController.h"
#import "GCYGroceryListViewModel.h"
#import "GCYUserController.h"
#import "HockeySDK.h"

@interface GCYAppDelegate () <BITHockeyManagerDelegate>
@end

@implementation GCYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	AFNetworkActivityIndicatorManager.sharedManager.enabled = YES;

	#ifdef GCY_HOCKEYAPP_IDENTIFIER
	[BITHockeyManager.sharedHockeyManager configureWithIdentifier:@(metamacro_stringify(GCY_HOCKEYAPP_IDENTIFIER)) delegate:self];
	[BITHockeyManager.sharedHockeyManager startManager];
	[BITHockeyManager.sharedHockeyManager.authenticator authenticateInstallation];
	#endif

	self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	self.window.backgroundColor = UIColor.whiteColor;

	GCYGroceryListViewModel *viewModel = [[GCYGroceryListViewModel alloc] init];
	GCYGroceryListViewController *listViewController = [[GCYGroceryListViewController alloc] initWithViewModel:viewModel];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listViewController];
	navigationController.navigationBar.translucent = NO;

	self.window.rootViewController = navigationController;
	[self.window makeKeyAndVisible];

	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	if (![URL.scheme isEqual:@"grocery-list"]) return NO;

	[OCTClient completeSignInWithCallbackURL:URL];
	return YES;
}

@end
