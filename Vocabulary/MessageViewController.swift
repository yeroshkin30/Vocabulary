//
//  MessageViewController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 12/23/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
	
	var message: Message?
	
	var messageResponsAction: (() -> Void)?
	
	@IBOutlet private var messageTitleLabel: UILabel!
	@IBOutlet private var messageTextLabel: UILabel!
	
	@IBOutlet private var messageResponsButton: UIButton!
	
	@IBAction private func messageResponsButtonAction(_ sender: UIButton) {
		messageResponsAction?()
	}
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		messageResponsButton.isHidden = messageResponsAction == nil
		updateMessageLabels()
	}
	
	private func updateMessageLabels() {
		messageTitleLabel.text = message?.title
		messageTextLabel.text = message?.text
		messageResponsButton.setTitle(message?.actionTitle, for: .normal)
	}
}

// MARK: - Types
extension MessageViewController {
	
	struct Message {
		let title: String
		let text: String
		let actionTitle: String?
	}
}
