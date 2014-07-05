//
//  GroceryList.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-04.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import Foundation

// TODO: A sensible Hashable implementation crashes the compiler
struct GroceryList: Equatable {
	let items: Dictionary<GroceryItem, ()>
	let stores: Dictionary<GroceryStore, ()>
}

@infix func ==(lhs: GroceryList, rhs: GroceryList) -> Bool {
	return lhs.items == rhs.items && lhs.stores == rhs.stores
}
