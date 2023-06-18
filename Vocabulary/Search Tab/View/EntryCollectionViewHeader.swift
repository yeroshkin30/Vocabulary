//
//  HeaderCollectionView.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 3/17/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class EntryCollectionViewHeader: UICollectionReusableView {
		
	@IBOutlet private var contentView: UIView!
	@IBOutlet private var title: UILabel!
	@IBOutlet private var subtitle: UILabel!
	@IBOutlet private var seeAlsoStackView: UIStackView!
	@IBOutlet private var button: UIButton!
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	private func viewDataDidChanged() {
		guard let viewData = viewData else { return }
		
		title.text = viewData.title
		subtitle.text = viewData.subtitle
		button.setTitle(viewData.buttonText, for: .normal)
		
		subtitle.isHidden = viewData.subtitle.isEmpty
		button.isHidden = viewData.buttonText.isEmpty
		seeAlsoStackView.isHidden = viewData.buttonText.isEmpty && viewData.subtitle.isEmpty
	}
}

extension EntryCollectionViewHeader {
	struct ViewData {
		let title: String
		let subtitle: String
		let buttonText: String
		
		init(entry: Entry) {
			title = entry.headword
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
