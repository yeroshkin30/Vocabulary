//
//	LearningCollectionViewCell.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/24/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class LearningCollectionViewCell: CardCollectionView {
	
	@IBOutlet private var headwordLabel: UILabel!
	@IBOutlet private var definitionLabel: UILabel!
	@IBOutlet var answerTextField: UITextField!
	
	private let correctAnswerColor: UIColor = #colorLiteral(red: 0.1607843137, green: 0.8039215686, blue: 0.2588235294, alpha: 1)
	private let incorrectAnswerColor: UIColor = #colorLiteral(red: 0.9982287288, green: 0.3754529953, blue: 0.3474243283, alpha: 1)
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		defaultAnswerTextFieldAttributes = convertFromNSAttributedStringKeyDictionary(answerTextField.defaultTextAttributes)
	}
	
	private func viewDataDidChanged() {
		guard let viewData: ViewData = viewData else { return }
		
		deselect()
		
		headwordLabel.text = viewData.headword
		headwordLabel.isHidden = true
		
		answerTextField.defaultTextAttributes = convertToNSAttributedStringKeyDictionary(defaultAnswerTextFieldAttributes)
		answerTextField.text = ""
		answerTextField.isHidden = false
		
		definitionLabel.text = viewData.definition
		
		setupShadowPath(for: frame.size)
	}
	
	func selectToAnswer(_ answer: AnswerCorrectness) {
		switch answer {
		case .correct:
			select(with: correctAnswerColor)
		case .incorrect:
			headwordLabel.isHidden = false
			answerTextField.isHidden = !answerTextField.hasText
			let incorrectText: NSAttributedString? = answerTextField.text?.strikethroughText(with: incorrectAnswerColor)
			answerTextField.attributedText = incorrectText
			
			select(with: incorrectAnswerColor)
		}
	}
	
	private var defaultAnswerTextFieldAttributes: [String: Any] = [:]
}

extension LearningCollectionViewCell {
	struct ViewData {
		let headword: String
		let definition: String
		
		init(word: Word) {
			headword = word.headword
			definition = word.definition
		}
	}
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
