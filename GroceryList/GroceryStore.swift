//
//  GroceryStore.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-04.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import Foundation

struct GroceryStore: Equatable, Hashable {
	let name: String
	
	var hashValue: Int {
		get {
			return name.lowercaseString.hashValue
		}
	}
}

@infix func ==(lhs: GroceryStore, rhs: GroceryStore) -> Bool {
	return lhs.name.caseInsensitiveCompare(rhs.name) == NSComparisonResult.OrderedSame
}
