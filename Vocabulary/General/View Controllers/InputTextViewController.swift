//
//	InputTextViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/12/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

enum CharactersNumberPreset: Int {
	case verySmall = 15, small = 50, medium = 100, large = 200
}

class InputTextViewController: UIViewController {

	// MARK: - Initialization

	private let initialText: String?
	private let charactersCapacity: CharactersNumberPreset
	private let inputTextDidFinishHandler: ((String) -> Void)

	init?(
		coder: NSCoder,
		title: String,
		initialText: String? = nil,
		charactersCapacity: CharactersNumberPreset,
		inputTextDidFinishHandler: @escaping ((String) -> Void)
	) {
		self.initialText = initialText
		self.charactersCapacity = charactersCapacity
		self.inputTextDidFinishHandler = inputTextDidFinishHandler

		super.init(coder: coder)

		self.title = title
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Outlets -
	
	@IBOutlet private var saveButton: UIBarButtonItem!
	@IBOutlet private var textView: UITextView!
	@IBOutlet private var limitOfCharactersLabel: UILabel!
	
	@IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		textView.becomeFirstResponder()
		navigationController?.navigationBar.setNeedsLayout()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		textView.resignFirstResponder()
	}
	
	override var textInputContextIdentifier: String? {
		return InputTextViewController.stringIdentifier
	}
}

// MARK: - Actions
private extension InputTextViewController {

	@IBAction
	func saveAction(_ sender: UIBarButtonItem?) {
		dismiss(animated: true) {
			self.inputTextDidFinishHandler(self.textView.text)
		}
	}

	@IBAction
	func cancelAction(_ sender: UIBarButtonItem?) {
		dismiss(animated: true)
	}
}

// MARK: - Private
private extension InputTextViewController {

	func setup() {
		navigationController?.presentationController?.delegate = self
		textView.text = initialText ?? ""
		textDidChange()
		textView.inputAccessoryView = limitOfCharactersLabel
		NotificationCenter.default.addObserver(
			self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil
		)
	}

	func textDidChange() {
		let currentNumber = textView.text.count
		let remainingNumber = charactersCapacity.rawValue - currentNumber

		limitOfCharactersLabel.text = String(remainingNumber)

		limitOfCharactersLabel.textColor = remainingNumber >= 0 ? .darkGray : .red
		saveButton.isEnabled = remainingNumber < charactersCapacity.rawValue && remainingNumber >= 0
	}

	@objc
	func keyboardDidShow(_ notification: Notification) {
		if let endFrame = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
			textViewBottomConstraint.constant = endFrame.size.height
		}
	}

	func showDismissAlert() {
		let presenter = DismissActionSheetPresenter(discardHandler: {
			self.cancelAction(nil)
		}, saveHandler: {
			self.saveAction(nil)
		}, cancelHandler: {
			self.textView.becomeFirstResponder()
		})

		presenter.present(in: self)
	}
}

extension InputTextViewController: UITextViewDelegate {

	func textViewDidChange(_ textView: UITextView) {
		textDidChange()
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension InputTextViewController: UIAdaptivePresentationControllerDelegate {

	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		let hasEditedText = textView.hasText
		let textIsDifferent = textView.text != initialText

		return !(hasEditedText && textIsDifferent)
	}

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		textView.resignFirstResponder()
		showDismissAlert()
	}
}
