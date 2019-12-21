//
//  DismissActionSheetPresenter.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 21.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

struct DismissActionSheetPresenter {

	let discardHandler: (() -> Void)?
	let saveHandler: (() -> Void)?
	let cancelHandler: (() -> Void)?

	init(discardHandler: (() -> Void)? = nil, saveHandler: (() -> Void)? = nil,  cancelHandler: (() -> Void)? = nil) {
		self.discardHandler = discardHandler
		self.saveHandler = saveHandler
		self.cancelHandler = cancelHandler
	}

	func present(in viewController: UIViewController) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { (_) in
			self.discardHandler?()
		})
		alert.addAction(UIAlertAction(title: "Save Changes", style: .default) { (_) in
			self.saveHandler?()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			self.cancelHandler?()
		})

		viewController.present(alert, animated: true)
	}
}
