//
//  GroceryItem.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-04.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import Foundation

struct GroceryItem: Hashable, Equatable {
	let name: String
	let stores: Dictionary<GroceryStore, ()>
	let isInCart: Bool

	var hashValue: Int {
		get {
			return name.lowercaseString.hashValue
		}
	}
}

@infix func ==(lhs: GroceryItem, rhs: GroceryItem) -> Bool {
	return lhs.name.caseInsensitiveCompare(rhs.name) == NSComparisonResult.OrderedSame
}
