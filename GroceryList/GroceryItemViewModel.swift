//
//  GroceryItemViewModel.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-05.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct GroceryItemViewModel: Equatable {
	let list: GroceryList
	let item: GroceryItem

	let isInCart: SignalingProperty<Bool>

	init(list: GroceryList, item: GroceryItem) {
		self.list = list
		self.item = item
		self.isInCart = SignalingProperty(item.isInCart)
	}
}

@infix func ==(lhs: GroceryItemViewModel, rhs: GroceryItemViewModel) -> Bool {
	return lhs.list == rhs.list && lhs.item == rhs.item
}
