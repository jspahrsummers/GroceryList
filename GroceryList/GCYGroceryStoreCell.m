//
//  GCYGroceryStoreCell.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryStoreCell.h"

#import "GCYGroceryStore.h"
#import "GCYGroceryStoreViewModel.h"

@implementation GCYGroceryStoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self == nil) return nil;

	RAC(self.textLabel, text) = RACObserve(self, viewModel.displayName);
	RAC(self.textLabel, font) = [RACObserve(self, viewModel.store) map:^(GCYGroceryStore *store) {
		CGFloat fontSize = UIFont.labelFontSize;
		if (store == nil) {
			return [UIFont boldSystemFontOfSize:fontSize];
		} else {
			return [UIFont systemFontOfSize:fontSize];
		}
	}];

	return self;
}

@end
