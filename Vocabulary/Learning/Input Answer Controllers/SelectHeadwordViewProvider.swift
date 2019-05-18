//
//	SelectHeadwordViewProvider.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/1/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

protocol SelectHeadwordViewProviderDelegate: AnyObject {
	func selectHeadwordViewProvider(_ provider: SelectHeadwordViewProvider,
									didSelect headword: String)
}

class SelectHeadwordViewProvider: HeadwordInputViewProvider {
	
	weak var delegate: SelectHeadwordViewProviderDelegate?
	
	// MARK: - HeadwordInputController
	
	var headword: String? { didSet { updateCurrentOptions() } }
	
	var inputView: UIView {
		return selectHeadwordInputView
	}
	
	private let context: NSManagedObjectContext
	
	init(context: NSManagedObjectContext) {
		self.context = context
	}
	
	private lazy var selectHeadwordInputView = initializeSelectHeadwordInputView()
	
	private let dummyHeadwords: [String] = [
		"Receiver", "Explicit", "Give", "Relative", "Believe", "Source", "Demand", "About",
		"Execute", "Important", "Basically", "Entity", "Feature", "Reception"
	]
	
	private lazy var savedHeadwordsFetchRequest: NSFetchRequest<NSFetchRequestResult> = {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
		fetchRequest.propertiesToFetch = [#keyPath(Word.headword)]
		fetchRequest.resultType = .dictionaryResultType
		fetchRequest.returnsDistinctResults = true
		fetchRequest.fetchLimit = 30
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(Word.learningStageValue), ascending: true)
		]
		return fetchRequest
	}()
	
	private var savedHeadwordsNumber: Int {
		return (try? context.count(for: savedHeadwordsFetchRequest)) ?? 0
	}
	
	private lazy var savedHeadwords: [String] = {
		let fetchedDictionary = (try? context.fetch(savedHeadwordsFetchRequest)) as? [[String:String]]
		
		return fetchedDictionary?.compactMap({ $0[#keyPath(Word.headword)] }) ?? []
	}()
	
	private lazy var sourceHeadwords: [String] = {
		if savedHeadwordsNumber >= dummyHeadwords.count {
			return savedHeadwords
		} else {
			return dummyHeadwords
		}
	}()
	
	private var currentOptions: [String] = [] {
		didSet {
			let viewData = SelectHeadwordInputView.ViewData(headwords: currentOptions)
			selectHeadwordInputView.viewData = viewData
		}
	}
	
	// MARK: - Helpers
	
	private func initializeSelectHeadwordInputView() -> SelectHeadwordInputView {
		let nib = UINib(nibName: SelectHeadwordInputView.stringIdentifier, bundle: nil)
		let selectHeadwordInputView = nib
			.instantiate(withOwner: nil, options: nil).first as! SelectHeadwordInputView
		
		selectHeadwordInputView.optionSelectedAction = { [weak self] (selectedOptionIndex) in
			guard let self = self else { return }
			let option = self.currentOptions[selectedOptionIndex]
			self.delegate?.selectHeadwordViewProvider(self, didSelect: option)
		}
		
		return selectHeadwordInputView
	}
	
	private func updateCurrentOptions() {
		guard let headword = headword else { return }
		
		let optionsNumber = selectHeadwordInputView.optionsNumber
		
		var optionHeadwords: [String] = [headword]
		
		while optionHeadwords.count < optionsNumber {
			let optioIndex = Int.random(in: 0..<sourceHeadwords.count)
			let option = sourceHeadwords[optioIndex]
			
			if !optionHeadwords.contains(option) {
				optionHeadwords.append(option)
			}
		}
		
		currentOptions = optionHeadwords.shuffled()
	}
}
