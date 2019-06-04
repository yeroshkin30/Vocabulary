//
//	LearningTypesViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/24/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class LearningTypesViewController: UIViewController, SegueHandlerType {
	
	// MARK: - Types
	
	enum LearningType: Int {
		case rememberWords, repeatWords, remindWords
	}
	
	// MARK: - Public propertis -
	
	var vocabularyStore: VocabularyStore!
	
	// MARK: - Outlets -
	
	@IBOutlet private var learningTypeTitles: [LearningTypeTitleView]!

	// MARK: - Life cycle
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLearningTypeTitles()
		setupNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		removeNotifications()
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case remembering, repetition, remindWord
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
		case .remembering:
			let viewController = segue.destination as! UnknownWordsViewController
			viewController.vocabularyStore = vocabularyStore
			
		case .repetition:
			let viewController = segue.destination as! LearningProcessViewController
			viewController.vocabularyStore = vocabularyStore
			
			let fetchRequest = FetchRequestFactory.fetchRequest(for: .repetition)
			let words = vocabularyStore.wordsFrom(fetchRequest)
			
			viewController.learningMode = .repetition(words)
			
		case .remindWord:
			let viewController = segue.destination as! RemindWordsViewController
			viewController.vocabularyStore = vocabularyStore
		}
	}
}

// MARK: - Private -
private extension LearningTypesViewController {
	
	func setupNotifications() {
		let name = UIApplication.willEnterForegroundNotification
		NotificationCenter.default.addObserver(
			self, selector: #selector(updateLearningTypeTitles), name: name, object: nil
		)
	}
	
	func removeNotifications() {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func updateLearningTypeTitles() {
		
		for (index, titleView) in learningTypeTitles.enumerated() {
			
			let learningType = LearningType(rawValue: index)!
			
			let number = numberOfWords(for: learningType)
			titleView.wordsNumberLable.text = String(number)
			titleView.titleButton.isEnabled = number == 0 ? false : true
			titleView.alpha = number == 0 ? 0.5 : 1.0
		}
	}
	
	func numberOfWords(for learningType: LearningType) -> Int {
		let fetchRequest: NSFetchRequest<Word>
		
		switch learningType {
		case .rememberWords:	fetchRequest = FetchRequestFactory.fetchRequest(for: .remembering)
		case .repeatWords:		fetchRequest = FetchRequestFactory.fetchRequest(for: .repetition)
		case .remindWords:		fetchRequest = FetchRequestFactory.fetchRequest(for: .reminding)
		}
		return vocabularyStore.numberOfWordsFrom(fetchRequest)
	}
}
