//
//  LearningModesView.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 06.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class LearningModesView: UIView {

	@IBOutlet private var rememberTypeTitles: LearningModeTitleView!
	@IBOutlet private var repeatTypeTitles: LearningModeTitleView!
	@IBOutlet private var remindTypeTitles: LearningModeTitleView!

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

	private func configureTitleView(_ view: LearningModeTitleView, with number: Int) {
		view.wordsNumberLabel.text = "\(number)"
		view.titleButton.isEnabled = number > 0
		view.alpha = number == 0 ? 0.5 : 1.0
	}
}

extension LearningModesView {

	struct ViewData {
		let rememberWordsNumber, repeatWordsNumber, remindWordsNumber: Int
	}
}
