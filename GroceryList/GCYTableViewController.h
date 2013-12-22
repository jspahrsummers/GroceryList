//
//  GCYTableViewController.h
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewController.h"

// Displays a table view for its UI.
//
// Unlike `UITableViewController`, this controller's `view` is not the table
// view itself. This means it is possible to insert content above the table
// view.
@interface GCYTableViewController : GCYViewController <UITableViewDataSource, UITableViewDelegate>

// A table view controller managing `tableView` and set up as a child of the
// receiver.
@property (nonatomic, strong, readonly) UITableViewController *childTableViewController;

// The table view controlled by the receiver.
@property (nonatomic, strong, readonly) UITableView *tableView;

@end
