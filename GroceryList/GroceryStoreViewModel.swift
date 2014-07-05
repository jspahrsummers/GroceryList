//
//  GroceryStoreViewModel.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-05.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import Foundation

struct GroceryStoreViewModel: Equatable {
	let store: GroceryStore?

	var displayName: String {
		get {
			if let s = store {
				return s.name
			} else {
				return NSLocalizedString("All Stores", comment: "")
			}
		}
	}

	init(store: GroceryStore?) {
		self.store = store
	}

	static func allStoresViewModel() -> GroceryStoreViewModel {
		return self(store: nil)
	}
}

@infix func ==(lhs: GroceryStoreViewModel, rhs: GroceryStoreViewModel) -> Bool {
	return lhs.store == rhs.store
}
