//
//  SequenceExtensions.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-05.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import Foundation

func hash<H: Hashable, S: Sequence where S.GeneratorType.Element == H>(sequence: S) -> Int {
	return reduce(sequence, 0) { (hash, elem) in hash ^ elem.hashValue }
}
