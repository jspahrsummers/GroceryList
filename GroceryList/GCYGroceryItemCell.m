//
//  GCYGroceryItemCell.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-18.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItemCell.h"
#import "GCYGroceryItem.h"
#import "GCYGroceryItemViewModel.h"

@implementation GCYGroceryItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self == nil) return nil;

	RACSignal *inCart = RACObserve(self, viewModel.inCart);
	RACSignal *name = RACObserve(self, viewModel.item.name);

	RAC(self.textLabel, attributedText) = [[[name
		map:^(NSString *name) {
			return [[NSAttributedString alloc] initWithString:name ?: @""];
		}]
		combineLatestWith:inCart]
		reduceEach:^ NSAttributedString * (NSAttributedString *text, NSNumber *inCart) {
			if (!inCart.boolValue) return text;

			NSMutableAttributedString *mutableText = [text mutableCopy];
			[mutableText addAttribute:NSForegroundColorAttributeName value:UIColor.grayColor range:NSMakeRange(0, mutableText.length)];
			[mutableText addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, mutableText.length)];
			return mutableText;
		}];

	return self;
}

@end
