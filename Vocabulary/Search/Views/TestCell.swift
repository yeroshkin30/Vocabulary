//
//  TestCell.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 18.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

private let numberOfExamples = 3
private let widthMultiplier: CGFloat = 0.9

class TestCell: CardCollectionView {

	@IBOutlet private var definitionLabel: UILabel!
	@IBOutlet private var examplesLabel: UILabel!
	@IBOutlet private var stackView: UIStackView!

	var viewData: ViewData? { didSet { viewDataDidChanged() } }

	override func awakeFromNib() {
		super.awakeFromNib()

//		let screeWidth = UIScreen.main.bounds.size.width
//		widthConstraint.constant = screeWidth * widthMultiplier
	}

	override func preferredLayoutAttributesFitting(
		_ layoutAttributes: UICollectionViewLayoutAttributes
	) -> UICollectionViewLayoutAttributes {

		let screeWidth = UIScreen.main.bounds.size.width

		setNeedsLayout()
		layoutIfNeeded()
		let size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		var frame = layoutAttributes.frame
		frame.size.height = ceil(size.height)
		frame.size.width = screeWidth * widthMultiplier
		layoutAttributes.frame = frame
		return layoutAttributes
	}

	private func viewDataDidChanged() {
		guard let viewData = viewData else { return }
		definitionLabel.text = viewData.definition
		examplesLabel.text = viewData.examples
		setupShadowPath(for: bounds.size)
	}
}

extension TestCell {

	struct ViewData {
		let definition, examples: String

		init(definition: Definition) {
			self.definition = definition.text
			let examples = definition.examples.prefix(numberOfExamples)
			self.examples = examples.joined(separator: "\n\n")
		}
	}
}
