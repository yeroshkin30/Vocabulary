//
//  LearningOptionsView.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 06.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class LearningOptionsView: UIView {

	@IBOutlet private var rememberTypeTitles: LearningOptionTitleView!
	@IBOutlet private var repeatTypeTitles: LearningOptionTitleView!
	@IBOutlet private var remindTypeTitles: LearningOptionTitleView!

	var viewData: ViewData = .init(rememberWordsNumber: 0, repeatWordsNumber: 0, remindWordsNumber: 0) {
		didSet {
			setNeedsLayout()
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		configureTitleView(rememberTypeTitles, with: viewData.rememberWordsNumber)
		configureTitleView(repeatTypeTitles, with: viewData.repeatWordsNumber)
		configureTitleView(remindTypeTitles, with: viewData.remindWordsNumber)
	}

	private func configureTitleView(_ view: LearningOptionTitleView, with number: Int) {
		view.wordsNumberLabel.text = "\(number)"
		view.titleButton.isEnabled = number == 0 ? false : true
		view.alpha = number == 0 ? 0.5 : 1.0
	}
}

extension LearningOptionsView {

	struct ViewData {
		let rememberWordsNumber, repeatWordsNumber, remindWordsNumber: Int
	}
}
