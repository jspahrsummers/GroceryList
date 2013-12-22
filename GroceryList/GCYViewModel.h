//
//  GCYViewModel.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-12-11.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

@interface GCYViewModel : RVMViewModel

// A unified signal of all errors that have occurred within the view model.
@property (nonatomic, strong, readonly) RACSignal *errors;

@end
