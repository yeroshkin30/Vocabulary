//
//	EditTextViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/12/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol EditTextViewControllerDelegate: AnyObject {
	func editTextViewController(_ controller: EditTextViewController, saveEditedText text: String)
}

class EditTextViewController: UIViewController, UITextViewDelegate {
	
	enum CharactersCapacity: Int {
		case verySmall = 10, small = 50, medium = 100, large = 200
	}
	
	var initialText: String?
	
	var charactersCapacity: CharactersCapacity = .small
	
	weak var delegate: EditTextViewControllerDelegate?
	
	// MARK: - Outlets -
	
	@IBOutlet private var saveButton: UIBarButtonItem!
	@IBOutlet private var textView: UITextView!
	@IBOutlet private var limitOfCharactersLabel: UILabel!
	
	@IBOutlet private weak var textViewBottmConstreint: NSLayoutConstraint!
	
	// MARK: - Actions
	
	@IBAction private func saveAction(_ sender: UIBarButtonItem) {
		let resultText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
		delegate?.editTextViewController(self, saveEditedText: resultText)
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		textView.becomeFirstResponder()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		textView.resignFirstResponder()
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
	}
	
	override var textInputContextIdentifier: String? {
		return EditTextViewController.stringIdentifier
	}
	
	// MARK: - Helpers
	
	private func setup() {
		textView.text = initialText ?? ""
		textDidChange()
		textView.inputAccessoryView = limitOfCharactersLabel
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
												name: UIResponder.keyboardDidShowNotification, object: nil)
	}
	
	private func textDidChange() {
		let currentNumber = textView.text.count
		let remainingNumber = charactersCapacity.rawValue - currentNumber
		
		limitOfCharactersLabel.text = String(remainingNumber)
		
		limitOfCharactersLabel.textColor = remainingNumber >= 0 ? .darkGray : .red
		saveButton.isEnabled = remainingNumber < charactersCapacity.rawValue && remainingNumber >= 0
	}
	
	@objc private func keyboardDidShow(_ notification: Notification) {
		if let endFrame = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
			
			textViewBottmConstreint.constant = endFrame.size.height
		}
	}
	
	// MARK: - UITextViewDelegate
	
	func textViewDidChange(_ textView: UITextView) {
		textDidChange()
	}
}
