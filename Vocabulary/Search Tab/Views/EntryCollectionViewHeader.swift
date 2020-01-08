//
//	EntryCollectionViewHeader.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/17/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class EntryCollectionViewHeader: UICollectionReusableView {
	
	@IBOutlet private var contentView: UIView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var subtitleLabel: UILabel!
	@IBOutlet private var subtitleStackView: UIStackView!
	@IBOutlet private var subtitleButton: UIButton!
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }

	var subtitleButtonTapHandler: (() -> Void)?

	override func prepareForReuse() {
		super.prepareForReuse()

		viewData = nil
		subtitleButtonTapHandler = nil
	}
	
	private func viewDataDidChanged() {
		guard let viewData = viewData else { return }
		
		titleLabel.text = viewData.title
		subtitleLabel.text = viewData.subtitle
		subtitleButton.setTitle(viewData.buttonTitle, for: .normal)

		subtitleLabel.isHidden = viewData.subtitle.isEmpty
		subtitleButton.isHidden = viewData.buttonTitle.isEmpty
		subtitleStackView.isHidden = viewData.buttonTitle.isEmpty && viewData.subtitle.isEmpty

		subtitleButton.sizeToFit()
	}

	@IBAction
	private func subtitleButtonTapAction(_ sender: UIButton) {
		subtitleButtonTapHandler?()
	}
}

extension EntryCollectionViewHeader {
	
	struct ViewData {
		let title, subtitle, buttonTitle: String
		
		init(entry: Entry) {
			title = entry.sentencePart
			subtitle = ""
			buttonTitle = ""
		}
		
		init(expression: Expression) {
			title = expression.text
			subtitle = expression.seeAlso.isEmpty ? "" : "see also:"
			buttonTitle = expression.seeAlso
		}
	}
}
