//
//	RemindWordCollectionViewCell.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/9/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class RemindWordCollectionViewCell: FullCardCollectionViewCell {
	
	// MARK: - Overriden -
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		optionsMode = .twoOption
		definitionView.isHidden = true
	}
	
	override func optionsModeDidChange() {
		guard let viewData = viewData else { return }
		
		switch optionsMode {
		case .oneOption:
			UIView.animate(withDuration: 0.35) {
				self.definitionView.isHidden = false
				self.negativeOptionButton.isHidden = true
				self.positiveOptionButton.setTitle(viewData.singleTitle, for: .normal)
			}
		case .twoOption:
			definitionView.isHidden = true
			negativeOptionButton.isHidden = false
			positiveOptionButton.setTitle(viewData.positiveTitle, for: .normal)
		}
	}
}
