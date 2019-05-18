//
//	MessageCollectionViewHeader.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/12/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class MessageCollectionViewHeader: UICollectionReusableView {
	
	@IBOutlet private weak var messageTitleLabel: UILabel!
	@IBOutlet private weak var messageLabel: UILabel!
	
	var titleText: String {
		get {
			return messageTitleLabel.text ?? ""
		}
		set {
			messageTitleLabel.text = newValue
		}
	}
	
	var messageText: String {
		get {
			return messageLabel.text ?? ""
		}
		set {
			messageLabel.text = newValue
		}
	}
}
