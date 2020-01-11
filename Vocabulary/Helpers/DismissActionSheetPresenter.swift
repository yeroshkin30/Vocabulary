//
//  DismissActionSheetPresenter.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 21.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

struct DismissActionSheetPresenter {

	let discardHandler: ((UIAlertAction) -> Void)?
	let saveHandler: ((UIAlertAction) -> Void)?
	let cancelHandler: ((UIAlertAction) -> Void)?

	init(
		discardHandler: ((UIAlertAction) -> Void)? = nil,
		saveHandler: ((UIAlertAction) -> Void)? = nil,
		cancelHandler: ((UIAlertAction) -> Void)? = nil
	) {
		self.discardHandler = discardHandler
		self.saveHandler = saveHandler
		self.cancelHandler = cancelHandler
	}

	func present(in viewController: UIViewController) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: discardHandler))
		if saveHandler != nil {
			alert.addAction(UIAlertAction(title: "Save Changes", style: .default, handler: saveHandler))
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))

		viewController.present(alert, animated: true)
	}
}
