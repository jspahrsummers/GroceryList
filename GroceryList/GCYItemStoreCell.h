//
//  GCYItemStoreCell.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-14.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

@class GCYGroceryItemStoreViewModel;

@interface GCYItemStoreCell : UITableViewCell

@property (nonatomic, strong) GCYGroceryItemStoreViewModel *viewModel;

@end
