//
//  GCYViewController.m
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2013-11-17.
//  Copyright (c) 2013 Justin Spahr-Summers. All rights reserved.
//

#import "GCYViewController.h"
#import "GCYViewModel.h"

@implementation GCYViewController

#pragma mark Lifecycle

- (id)initWithViewModel:(GCYViewModel *)viewModel {
	return [self initWithViewModel:viewModel nibName:nil bundle:nil];
}

- (id)initWithViewModel:(GCYViewModel *)viewModel nibName:(NSString *)nibName bundle:(NSBundle *)bundle {
	self = [super initWithNibName:nibName bundle:bundle];
	if (self == nil) return nil;

	_viewModel = viewModel;

	RACSignal *presented = [[RACSignal
		merge:@[
			[[self rac_signalForSelector:@selector(viewDidAppear:)] mapReplace:@YES],
			[[self rac_signalForSelector:@selector(viewWillDisappear:)] mapReplace:@NO]
		]]
		setNameWithFormat:@"%@ presented", self];

	RACSignal *appActive = [[[RACSignal
		merge:@[
			[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] mapReplace:@YES],
			[[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] mapReplace:@NO]
		]]
		startWith:@YES]
		setNameWithFormat:@"%@ appActive", self];
	
	RAC(self, viewModel.active) = [[[RACSignal
		combineLatest:@[ presented, appActive ]]
		and]
		setNameWithFormat:@"%@ active", self];

	[self rac_liftSelector:@selector(presentError:) withSignals:self.viewModel.errors, nil];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
	overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
	[self.view addSubview:overlayView];

	UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[loadingView startAnimating];
	[overlayView addSubview:loadingView];

	RCLFrame(loadingView) = @{
		rcl_center: overlayView.rcl_boundsSignal.center
	};

	RAC(overlayView, alpha) = [[[[RACObserve(self, loading)
		distinctUntilChanged]
		map:^(NSNumber *loading) {
			return loading.boolValue ? @1 : @0;
		}]
		animateWithDuration:0.35 curve:RCLAnimationCurveLinear]
		startWith:@0];
}

#pragma mark Error handling

- (void)presentError:(NSError *)error {
	NSLog(@"%@", error);

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
	[alertView show];
}

@end
