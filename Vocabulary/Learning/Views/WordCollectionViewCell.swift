//
//	WordCollectionViewCell.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/24/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class WordCollectionViewCell: CardCollectionView {
	
	// MARK: - Public properties
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }
	
	var state: State = .bothAnswersVisible { didSet { stateDidChange() } }
	
	// MARK: - Outlets
	
	@IBOutlet private var headwordLabel: UILabel!
	@IBOutlet private var sentencePartLabel: UILabel!
	@IBOutlet private var definitionLabel: UILabel!
	@IBOutlet private var examplesLabel: UILabel!
	@IBOutlet private var examplesScrollView: UIScrollView!
	
	@IBOutlet var leftAnswerButton: UIButton!
	@IBOutlet var rightAnswerButton: UIButton!
	
	@IBOutlet var definitionView: UIView!
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		scrollToTop()
	}
	
	// MARK: - Private
	
	private func viewDataDidChanged() {
		guard let viewData = viewData else { return }
		
		headwordLabel.text = viewData.headword
		sentencePartLabel.text = viewData.sentencePart
		definitionLabel.text = viewData.definition
		examplesLabel.text = viewData.examples
		
		scrollToTop()
		setupShadowPath(for: frame.size)
	}
	
	func stateDidChange() {
		
		switch state {
		case .oneAnswersVisible:
			leftAnswerButton.isHidden = true
			rightAnswerButton.setTitle("Now", for: .normal)
		case .bothAnswersVisible:
			leftAnswerButton.isHidden = false
			leftAnswerButton.setTitle("Later", for: .normal)
			rightAnswerButton.setTitle("Now", for: .normal)
		}
	}
	
	private func scrollToTop() {
		let visibleRect = CGRect(x: 0, y: 0, width: 1, height: 1)
		examplesScrollView.scrollRectToVisible(visibleRect, animated: false)
	}
}

extension WordCollectionViewCell {
	
	struct ViewData {
		let headword, sentencePart, definition, examples: String
		
		init(word: Word) {
			headword = word.headword
			sentencePart = word.sentencePart
			definition = word.definition
			examples = word.examplesText
		}
	}
	
	enum State {
		case oneAnswersVisible, bothAnswersVisible
	}
}
