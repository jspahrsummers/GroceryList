//
//  ViewController.swift
//  GroceryList
//
//  Created by Justin Spahr-Summers on 2014-07-04.
//  Copyright (c) 2014 Justin Spahr-Summers. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ViewController: UIViewController {
	let loading = SignalingProperty(false)

	let _presented = SignalingProperty(false)
	var presented: Signal<Bool> {
		get {
			return _presented
		}
	}
	
	init(nibName: String? = nil, bundle: NSBundle? = nil) {
		super.init(nibName: nibName, bundle: bundle)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		_presented.current = true
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		_presented.current = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let overlayView = UIView(frame: view.bounds)
		overlayView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
		overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.65)
		view.addSubview(overlayView)

		let loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
		loadingView.startAnimating()
		overlayView.addSubview(loadingView)

		// TODO: Add constraints to loadingView here.

		// TODO: Animate these changes.
		self.loading
			.skipRepeats(identity)
			.map { loading in loading ? 1.0 : 0.0 }
			.observe { overlayView.alpha = $0 }
	}

	func presentError(error: NSError) {
		let alertView = UIAlertView()
		alertView.title = error.localizedDescription
		alertView.message = error.localizedRecoverySuggestion
		alertView.addButtonWithTitle(NSLocalizedString("OK", comment: ""))
		alertView.show()
	}
}
