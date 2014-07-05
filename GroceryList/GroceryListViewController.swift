//
//  GroceryListViewController.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-05.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import Foundation
import ReactiveCocoa

class GroceryListViewController: TableViewController {
	let viewModel: GroceryListViewModel

	init(viewModel: GroceryListViewModel) {
		self.viewModel = viewModel
		super.init()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		viewModel.selectedStore
			.map { $0.displayName }
			.observe { self.title = $0 }

		view.backgroundColor = UIColor.whiteColor()

		let refreshControl = UIRefreshControl()
		refreshControl.rac_signalForControlEvents(UIControlEvents.ValueChanged)
			.asSignalOfLatestValue()
			.observe {
				if $0 != nil {
					self.viewModel.loadItems.execute(())
				}
			}

		childTableViewController.refreshControl = refreshControl
	}

	override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		return viewModel.items.current.items.count
	}

	override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
		let cell = tableView?.dequeueReusableCellWithIdentifier(NSStringFromClass(GroceryItemCell.self), forIndexPath: indexPath) as GroceryItemCell
		cell.viewModel.current = viewModel.items.current[indexPath!.row]
		return cell
	}

	func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
		return true
	}

	func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
		assert(editingStyle == UITableViewCellEditingStyle.Delete)

		viewModel.removeItem.execute(viewModel.items.current[indexPath!.row])
	}

	func tableView(tableView: UITableView?, willSelectRowAtIndexPath indexPath: NSIndexPath?) -> NSIndexPath? {
		let item = viewModel.items.current[indexPath!.row]
		item.isInCart.current = !item.isInCart.current

		return nil
	}
}
