//
//  DefinitionCollectionViewCell.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 10/4/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

private let numberOfExamples = 2

class DefinitionCollectionViewCell: CardView {

    @IBOutlet private var wordCategoryLabel: UILabel!
    @IBOutlet private var definitionLabel: UILabel!
    @IBOutlet private var examplesLabel: UILabel!
    @IBOutlet private var seeAlsoStackView: UIStackView!
    @IBOutlet private var seeAlsoButton: UIButton!
    @IBOutlet private var widthConstraint: NSLayoutConstraint!
	
	override var isSelected: Bool {
		didSet {
			if isSelected {
				select(with: #colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1))
			} else {
				deselect()
			}
		}
	}
    
    var viewData: ViewData? { didSet { viewDataDidChanged() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
        let screeWidth = UIScreen.main.bounds.size.width
        widthConstraint.constant = screeWidth * 0.9
	}
	    
    private func viewDataDidChanged() {
        guard let viewData = viewData else { return }
		
		wordCategoryLabel.text = viewData.category
        definitionLabel.text = viewData.definition
        examplesLabel.text = viewData.examples
        
        seeAlsoStackView.isHidden = viewData.seeAlso.isEmpty
        seeAlsoButton.setTitle(viewData.seeAlso, for: .normal)
		
		updateShadow()
	}
}

extension DefinitionCollectionViewCell {
    struct ViewData {
        let category: String
        let definition: String
        let examples: String
        let seeAlso: String
		
		init(definition: Definition) {
            self.category = definition.category
            self.definition = definition.text
            self.seeAlso = definition.seeAlso
			
			var examplesText = ""
			if !definition.examples.isEmpty {
				let examples = definition.examples.prefix(numberOfExamples)
				examplesText = examples.joined(separator: "\n\n")
			}
			self.examples = examplesText
        }
    }
}
