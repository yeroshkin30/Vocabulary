//
//	HeaderCollectionView.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/17/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class DefinitionsCollectionViewHeader: UICollectionReusableView {
	
	@IBOutlet private var contentView: UIView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var subtitleLabel: UILabel!
	@IBOutlet private var seeAlsoStackView: UIStackView!
	@IBOutlet private var seeAlsoButton: UIButton!
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }
	
	private func viewDataDidChanged() {
		guard let viewData = viewData else { return }
		
		titleLabel.text = viewData.title
		subtitleLabel.text = viewData.subtitle
		seeAlsoButton.setTitle(viewData.buttonText, for: .normal)
		
		subtitleLabel.isHidden = viewData.subtitle.isEmpty
		seeAlsoButton.isHidden = viewData.buttonText.isEmpty
		seeAlsoStackView.isHidden = viewData.buttonText.isEmpty && viewData.subtitle.isEmpty
	}
}

extension DefinitionsCollectionViewHeader {
	
	struct ViewData {
		let title, subtitle, buttonText: String
		
		init(entry: Entry) {
			title = ""
			subtitle = entry.sentencePart
			buttonText = ""
		}
		
		init(expression: Expression) {
			title = expression.text
			subtitle = expression.seeAlso.isEmpty ? "" : "see also:"
			buttonText = expression.seeAlso
		}
	}
}
