//
//  GCYGroceryItemStoreCell.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYGroceryItemStoreCell.h"

#import "GCYGroceryStore.h"
#import "GCYGroceryItemStoreViewModel.h"

@implementation GCYGroceryItemStoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self == nil) return nil;

	RAC(self.textLabel, text) = RACObserve(self, viewModel.store.name);
	RAC(self, accessoryType) = [RACObserve(self, viewModel.selected) map:^(NSNumber *selected) {
		return @(selected.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
	}];

	return self;
}

@end
