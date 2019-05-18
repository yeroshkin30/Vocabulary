//
//	RememberingCompletionCollectionViewCell.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/12/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

private let widthMultiplier: CGFloat = 0.9

class RememberingCompletionCollectionViewCell: CardCollectionView {
	
	@IBOutlet private var headwordLable: UILabel!
	@IBOutlet private var definitionLable: UILabel!
	
	@IBOutlet private var widthConstraint: NSLayoutConstraint!
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let screenWidth = UIScreen.main.bounds.width
		widthConstraint.constant = screenWidth * 0.9
	}
	
	override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
		return fittingSize
	}
	
	private var fittingSize: CGSize {
		return contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}
	
	private func viewDataDidChanged() {
		guard let viewData = viewData else { return }
		
		headwordLable.text = viewData.headword
		definitionLable.text = viewData.definition
		
		setupShadowPath(for: fittingSize)
	}
}

extension RememberingCompletionCollectionViewCell {
	struct ViewData {
		let headword: String
		let definition: String
		
		init(word: Word) {
			self.headword = word.headword
			self.definition = word.definition
		}
	}
}
