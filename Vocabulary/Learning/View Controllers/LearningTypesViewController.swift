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
		case rememberWords
		case repeatWords
		case remindWords
	}
	
	// MARK: - Public propertis -
	
	var vocabularyStore: VocabularyStore!
	
	// MARK: - Outlets -
	
	@IBOutlet private var learningTypeTitles: [LearningTypeTitleView]!

	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLearningTypeTitles()
		
		let name = UIApplication.willEnterForegroundNotification
		NotificationCenter.default.addObserver(
			self, selector: #selector(updateLearningTypeTitles), name: name, object: nil
		)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case remembering, repetition, remindWord
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
		case .remembering:
			let viewController = segue.destination as! UnknownWordsCollectionViewController
			viewController.vocabularyStore = vocabularyStore
			
		case .repetition:
			let viewController = segue.destination as! LearningProcessViewController
			viewController.vocabularyStore = vocabularyStore
			
			let fetchRequest = LearningTypeFetchRequest.repetition.request()
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
	
	private func removeNotifications() {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc private func updateLearningTypeTitles() {
		
		for (index, titleView) in learningTypeTitles.enumerated() {
			
			let learningType = LearningType(rawValue: index)!
			
			let number = numberOfWords(for: learningType)
			titleView.wordsNumberLable.text = String(number)
			titleView.titleButton.isEnabled = number == 0 ? false : true
			titleView.alpha = number == 0 ? 0.5 : 1.0
		}
	}
	
	private func numberOfWords(for learningType: LearningType) -> Int {
		let fetchRequest: NSFetchRequest<Word>
		
		switch learningType {
		case .rememberWords:
			fetchRequest = LearningTypeFetchRequest.unknown.request()
			
		case .repeatWords:
			fetchRequest = LearningTypeFetchRequest.repetition.request()
			
		case .remindWords:
			fetchRequest = LearningTypeFetchRequest.remind.request()
			
		}
		return vocabularyStore.numberOfWordsFrom(fetchRequest)
	}
}
