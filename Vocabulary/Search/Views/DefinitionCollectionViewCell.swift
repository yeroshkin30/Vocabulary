//
//	DefinitionCollectionViewCell.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 10/4/17.
//	Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

private let numberOfExamples = 3
private let widthMultiplier: CGFloat = 0.9

class DefinitionCollectionViewCell: CardCollectionView {
	
	@IBOutlet private var wordCategoryLabel: UILabel!
	@IBOutlet private var definitionLabel: UILabel!
	@IBOutlet private var examplesLabel: UILabel!
	@IBOutlet private var seeAlsoStackView: UIStackView!
	@IBOutlet private var seeAlsoButton: UIButton!

	var viewData: ViewData? { didSet { viewDataDidChanged() } }

	override func preferredLayoutAttributesFitting(
		_ layoutAttributes: UICollectionViewLayoutAttributes
	) -> UICollectionViewLayoutAttributes {

		setNeedsLayout()
		layoutIfNeeded()
		let size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		var frame = layoutAttributes.frame
		frame.size.height = size.height
		layoutAttributes.frame = frame
		return layoutAttributes
	}

	private func viewDataDidChanged() {
		guard let viewData = viewData else { return }
		
		wordCategoryLabel.text = viewData.category
		definitionLabel.text = viewData.definition
		examplesLabel.text = viewData.examples
		
		seeAlsoStackView.isHidden = viewData.seeAlso.isEmpty
		seeAlsoButton.setTitle(viewData.seeAlso, for: .normal)
		
		setupShadowPath(for: bounds.size)
	}
}

extension DefinitionCollectionViewCell {
	
	struct ViewData {
		let category, definition, examples, seeAlso: String
		
		init(definition: Definition) {
			self.category = definition.category
			self.definition = definition.text
			self.seeAlso = definition.seeAlso
			
			var examplesText = ""
			if !definition.examples.isEmpty {
				let examples = definition.examples.prefix(numberOfExamples).map({ "- " + $0 })
				examplesText = examples.joined(separator: "\n\n")
			}
			self.examples = examplesText
		}
	}
}
