//
//  GCYViewModel+Protected.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-11.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewModel.h"

@interface GCYViewModel () {
@protected
	RACSubject *_errors;
}

@end
