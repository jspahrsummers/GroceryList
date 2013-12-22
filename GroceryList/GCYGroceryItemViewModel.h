//
//  GCYGroceryItemViewModel.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewModel.h"

@class GCYGroceryItem;
@class GCYGroceryList;

@interface GCYGroceryItemViewModel : GCYViewModel

@property (nonatomic, strong, readonly) GCYGroceryList *list;
@property (nonatomic, strong, readonly) GCYGroceryItem *item;

// Whether the user has already gotten this item.
@property (nonatomic, getter = isInCart) BOOL inCart;

- (instancetype)initWithList:(GCYGroceryList *)list item:(GCYGroceryItem *)item;

@end
