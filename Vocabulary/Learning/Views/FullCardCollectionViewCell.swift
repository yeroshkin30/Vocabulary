//
//	FullCardCollectionViewCell.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/24/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class FullCardCollectionViewCell: CardCollectionView {
	
	enum Action {
		case single, positive, negative, pronounce
	}
	
	enum OptionsMode {
		case oneOption, twoOption
	}
	
	// MARK: - Public properties
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }
	
	var optionsMode: OptionsMode = .twoOption { didSet { optionsModeDidChange() } }
	
	var cellActionHandler: ((FullCardCollectionViewCell.Action) -> Void)?
	
	// MARK: - Outlets
	
	@IBOutlet private var headwordLabel: UILabel!
	@IBOutlet private var sentencePartLabel: UILabel!
	@IBOutlet private var definitionLabel: UILabel!
	@IBOutlet private var examplesLabel: UILabel!
	@IBOutlet private var examplesScrollView: UIScrollView!
	
	@IBOutlet var definitionView: UIView!
	@IBOutlet var negativeOptionButton: UIButton!
	@IBOutlet var positiveOptionButton: UIButton!
	
	// MARK: - Actions -
	
	@IBAction private func pronounceButtonAction(_ sender: UIButton) {
		cellActionHandler?(.pronounce)
	}
	
	@IBAction private func negativeOptionButtonAction(_ sender: UIButton) {
		cellActionHandler?(.negative)
	}
	
	@IBAction private func positiveOptionButtonAction(_ sender: UIButton) {
		switch optionsMode {
		case .oneOption: cellActionHandler?(.single)
		case .twoOption: cellActionHandler?(.positive)
		}
	}
	
	// MARK: - Overridden -
	
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
		
		positiveOptionButton.setTitle(viewData.positiveTitle, for: .normal)
		negativeOptionButton.setTitle(viewData.negativeTitle, for: .normal)
		
		scrollToTop()
	}
	
	func optionsModeDidChange() {
		guard let viewData = viewData else { return }
		
		switch optionsMode {
		case .oneOption:
			negativeOptionButton.isHidden = true
			positiveOptionButton.setTitle(viewData.singleTitle, for: .normal)
			
		case .twoOption:
			negativeOptionButton.isHidden = false
			negativeOptionButton.setTitle(viewData.negativeTitle, for: .normal)
			positiveOptionButton.setTitle(viewData.positiveTitle, for: .normal)
		}
	}
	
	private func scrollToTop() {
		let visibleRect = CGRect(x: 0, y: 0, width: 1, height: 1)
		examplesScrollView.scrollRectToVisible(visibleRect, animated: false)
	}
	
}

extension FullCardCollectionViewCell {
	
	struct ViewData {
		let headword, sentencePart, definition, examples: String
		let singleTitle, positiveTitle, negativeTitle: String
		let isDefinitionHidden: Bool
		
		init(word: Word) {
			headword = word.headword
			sentencePart = word.sentencePart
			definition = word.definition
			examples = word.examples.map({ "- " + $0 }).joined(separator: "\n\n")
			
			singleTitle = word.learningStage == .unknown ? "Now" : "Next"
			positiveTitle = word.learningStage == .unknown ? "Now" : "Remember"
			negativeTitle = word.learningStage == .unknown ? "Later" : "Forget"
			
			isDefinitionHidden = word.learningStage == .reminding
		}
	}
}
