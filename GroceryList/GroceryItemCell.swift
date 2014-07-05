//
//  GroceryItemCell.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-05.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import UIKit
import ReactiveCocoa

class GroceryItemCell: UITableViewCell {
	let viewModel = SignalingProperty<GroceryItemViewModel?>(nil)

	init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		let name = viewModel
					.map { $0?.item.name }
					.ignoreNil(identity, initialValue: "")

		let isInCart = viewModel
						.map { $0?.isInCart }
						.ignoreNil(identity, initialValue: .constant(false))
						.switchToLatest(identity)

		name.map { NSAttributedString(string: $0) }
			.combineLatestWith(isInCart)
			.map { (string, inCart) in
				if !inCart {
					return string
				}

				let mutableString = string.mutableCopy() as NSMutableAttributedString
				mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSMakeRange(0, string.length))
				mutableString.addAttribute(NSStrikethroughStyleAttributeName, value: NSUnderlineStyle.StyleSingle.toRaw(), range: NSMakeRange(0, string.length))
				return mutableString
			}
			.observe { self.textLabel.attributedText = $0 }
	}
}
