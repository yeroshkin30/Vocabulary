//
//	MessageView.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 1/17/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class MessageView: UIView {
	
	var message: Message? { didSet { messageDidChange() } }
	
	@IBOutlet private var messageTitleLabel: UILabel!
	@IBOutlet private var messageTextLabel: UILabel!
	
	@IBOutlet private var messageActionButton: UIButton!
	
	@IBAction private func messageResponseButtonAction(_ sender: UIButton) {
		message?.actionClosure?()
	}
	
	private func messageDidChange() {
		messageTitleLabel.text = message?.title
		messageTextLabel.text = message?.text
		messageActionButton.setTitle(message?.actionTitle, for: .normal)
		messageActionButton.isHidden = message?.actionClosure == nil
	}
}

// MARK: - Types
extension MessageView {
	
	struct Message {
		let title: String
		let text: String
		let actionTitle: String?
		let actionClosure: (() -> Void)?
		
		init(title: String, text: String, actionTitle: String? = nil, actionClosure: (() -> Void)? = nil) {
			self.title = title
			self.text = text
			self.actionTitle = actionTitle
			self.actionClosure = actionClosure
		}
	}
}
