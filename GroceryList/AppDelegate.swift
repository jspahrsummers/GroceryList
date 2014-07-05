//
//  AppDelegate.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-04.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow!

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		self.window.backgroundColor = UIColor.whiteColor()

		let listViewController = GroceryListViewController(viewModel: GroceryListViewModel())
		let navController = UINavigationController(rootViewController: listViewController)
		navController.navigationBar.translucent = false

		self.window.rootViewController = navController
		self.window.makeKeyAndVisible()

		return true
	}
}
