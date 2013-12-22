//
//  GCYViewController.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCYViewModel;

// Base view controller class.
@interface GCYViewController : UIViewController

// The view model for the receiver.
@property (nonatomic, strong, readonly) GCYViewModel *viewModel;

// Whether the receiver is loading content.
//
// When setting this property, a loading overlay will fade in or out
// automatically.
//
// Defaults to `NO`.
@property (nonatomic, getter = isLoading) BOOL loading;

// Initializes the receiver with a view model, and without a nib.
- (id)initWithViewModel:(GCYViewModel *)viewModel;

// Initializes the receiver with a view model, and optionally a nib and bundle.
//
// This is the designated initializer for this class.
- (id)initWithViewModel:(GCYViewModel *)viewModel nibName:(NSString *)nibName bundle:(NSBundle *)bundle;

// Displays an error to the user.
- (void)presentError:(NSError *)error;

@end
