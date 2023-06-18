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
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = .init(entityName: "Word")
		fetchRequest.propertiesToFetch = [#keyPath(Word.headword)]
		fetchRequest.resultType = .dictionaryResultType
		fetchRequest.returnsDistinctResults = true
		fetchRequest.fetchLimit = 30
		return fetchRequest
	}()
	
	private var savedHeadwordsNumber: Int {
		return (try? context.count(for: savedHeadwordsFetchRequest)) ?? 0
	}
	
	private lazy var savedHeadwords: [String] = {
		let fetchedDictionary: [[String : String]]? = (try? context.fetch(savedHeadwordsFetchRequest)) as? [[String:String]]
		
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
			let viewData: SelectHeadwordInputView.ViewData = .init(headwords: currentOptions)
			selectHeadwordInputView.viewData = viewData
		}
	}
	
	// MARK: - Helpers
	
	private func initializeSelectHeadwordInputView() -> SelectHeadwordInputView {

        let view: SelectHeadwordInputView = SelectHeadwordInputView.instantiate()

		view.optionSelectedAction = { [weak self] (selectedOptionIndex) in
			guard let self = self else { return }
			let option: String = self.currentOptions[selectedOptionIndex]
			self.delegate?.selectHeadwordViewProvider(self, didSelect: option)
		}
		
		return view
	}
	
	private func updateCurrentOptions() {
		guard let headword: String = headword else { return }
		
		let optionsNumber: Int = selectHeadwordInputView.optionsNumber
		
		var optionHeadwords: [String] = [headword]
		
		while optionHeadwords.count < optionsNumber {
			let optionIndex: Int = Int.random(in: 0..<sourceHeadwords.count)
			let option: String = sourceHeadwords[optionIndex]
			
			if !optionHeadwords.contains(option) {
				optionHeadwords.append(option)
			}
		}
		
		currentOptions = optionHeadwords.shuffled()
	}
}
