//
//  TableViewController.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-04.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import UIKit

class TableViewController: ViewController, UITableViewDataSource, UITableViewDelegate {
	let childTableViewController = UITableViewController(style: UITableViewStyle.Plain)

	var tableView: UITableView {
		get {
			return childTableViewController.tableView
		}
	}

	init(nibName: String? = nil, bundle: NSBundle? = nil) {
		super.init(nibName: nibName, bundle: bundle)

		addChildViewController(childTableViewController)
		childTableViewController.didMoveToParentViewController(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.frame = view.bounds
		tableView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
		tableView.delegate = self
		tableView.dataSource = self
		view.insertSubview(tableView, atIndex: 0)
	}

	func tableView(tableView: UITableView?, numberOfRowsInSection: Int) -> Int {
		assert(false)
		return 0
	}

	func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		assert(false)
		return nil
	}
}
