//
//  GroceryListViewModel.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-05.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct GroceryListViewModel {
	struct SortedList {
		let items: GroceryItemViewModel[]

		init() {
			items = []
		}

		init(_ unsortedItems: GroceryItemViewModel[]) {
			items = sort(unsortedItems) {
				return $0.item.name.localizedCaseInsensitiveCompare($1.item.name) == NSComparisonResult.OrderedAscending
			}
		}

		@conversion func __conversion() -> GroceryItemViewModel[] {
			return items
		}

		subscript(index: Int) -> GroceryItemViewModel {
			return items[index]
		}
	}

	let loadItems: Action<(), SortedList>
	let removeItem: Action<GroceryItemViewModel, SortedList>

	var items: Signal<SortedList> {
		get {
			return loadItems.results
				.ignoreNil(identity, initialValue: SortedList())
		}
	}

	let selectedStore = SignalingProperty(GroceryStoreViewModel.allStoresViewModel())
}
