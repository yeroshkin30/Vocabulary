//
//	SelectHeadwordInputView.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/1/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class SelectHeadwordInputView: UIInputView {
	
	// MARK: - Public properties
	
	var viewData: ViewData? { didSet { viewDataDidChanged() } }
	
	var optionSelectedAction: ((Int) -> Void)?
	
	var optionsNumber: Int {
		return optionsButtons.count
	}
	
	// MARK: - Outlets
	
	@IBOutlet private weak var optionsStackView: UIStackView!
	@IBOutlet private var optionsButtons: [UIButton]!
	
	private weak var selectedOptionButton: UIButton? {
		didSet {
			if let button: UIButton = selectedOptionButton {
				isUserInteractionEnabled = false
				button.select(with: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1))
			} else {
				isUserInteractionEnabled = true
				oldValue?.deselect()
			}
		}
	}
	
	@IBAction private func optionButtonTapped(_ sender: UIButton) {
		selectedOptionButton = sender
		
		if let selectedOptionIndex: Int = optionsButtons.firstIndex(of: sender) {
			optionSelectedAction?(selectedOptionIndex)
		}
	}
	
	private func viewDataDidChanged() {
		guard let viewData: ViewData = viewData else { return }
		
		selectedOptionButton = nil
		
		for (index, title) in viewData.headwords.enumerated() {
			optionsButtons[index].setTitle(title, for: .normal)
		}
	}
}

extension SelectHeadwordInputView {
	
	struct ViewData {
		let headwords: [String]
	}
}
