//
//	LetterCollectionViewCell.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/2/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class LetterCollectionViewCell: UICollectionViewCell {
	
	typealias LetterItemData = (letter: String, number: Int)
	
	@IBOutlet private weak var letterLabel: UILabel!
	@IBOutlet private weak var numberLabel: UILabel!
	
	var letterItemData: LetterItemData? {
		didSet {
			guard let itemData: LetterItemData = letterItemData else { return }
			letterLabel.text = itemData.letter.uppercased()
			numberLabel.text = "\(itemData.number)"
			numberLabel.isHidden = !(itemData.number > 1)
		}
	}
	
	func updateCornerRadius() {
		letterLabel.cornerRadius = letterLabel.frame.height / 2
		numberLabel.cornerRadius = numberLabel.frame.height / 2
	}
}
