//
//  NSString+GCYEnumerationAdditions.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-08.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GCYEnumerationAdditions)

// Sends each line in the string.
@property (nonatomic, strong, readonly) RACSignal *gcy_lineSignal;

@end
