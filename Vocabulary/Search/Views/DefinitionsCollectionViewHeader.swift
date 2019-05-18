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
	@IBOutlet private var title: UILabel!
	@IBOutlet private var subtitle: UILabel!
	@IBOutlet private var seeAlsoStackView: UIStackView!
	@IBOutlet private var seeAlsoButton: UIButton!
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
	}
	
	private func viewDataDidChanged() {
		guard let viewData = viewData else { return }
		
		title.text = viewData.title
		subtitle.text = viewData.subtitle
		seeAlsoButton.setTitle(viewData.buttonText, for: .normal)
		
		subtitle.isHidden = viewData.subtitle.isEmpty
		seeAlsoButton.isHidden = viewData.buttonText.isEmpty
		seeAlsoStackView.isHidden = viewData.buttonText.isEmpty && viewData.subtitle.isEmpty
	}
}

extension DefinitionsCollectionViewHeader {
	struct ViewData {
		let title: String
		let subtitle: String
		let buttonText: String
		
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
