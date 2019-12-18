//
//	LearningOptionsViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/24/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData.NSManagedObjectID

class LearningOptionsViewController: UIViewController, SegueHandlerType {

	// MARK: - Properties -

	var vocabularyStore: VocabularyStore!
	var currentWordCollectionInfoProvider: CurrentWordCollectionInfoProvider!

	@IBOutlet private var learningOptionsView: LearningOptionsView!

	private var currentWordCollectionID: NSManagedObjectID? {
		currentWordCollectionInfoProvider.wordCollectionInfo?.objectID
	}

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		setupNotifications()
		currentWordCollectionInfoProvider.addObserver(self)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLearningOptionsView()
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
			viewController.currentWordCollectionID = currentWordCollectionID
			
		case .repetition:
			let viewController = segue.destination as! LearningProcessViewController
			viewController.vocabularyStore = vocabularyStore
			viewController.currentWordCollectionID = currentWordCollectionID
			
			let fetchRequest = FetchRequestFactory.fetchRequest(for: .repetition, wordCollectionID: currentWordCollectionID)
			let words = vocabularyStore.wordsFrom(fetchRequest)
			
			viewController.learningMode = .repetition(words)
			
		case .remindWord:
			let viewController = segue.destination as! RemindWordsViewController
			viewController.vocabularyStore = vocabularyStore
			viewController.currentWordCollectionID = currentWordCollectionID
		}
	}
}

// MARK: - Private -
private extension LearningOptionsViewController {

	// MARK: - Methods
	
	func setupNotifications() {
		let enterForeground = UIApplication.willEnterForegroundNotification
		NotificationCenter.default.addObserver(
			self, selector: #selector(updateLearningOptionsView), name: enterForeground, object: nil
		)
	}
	
	@objc
	func updateLearningOptionsView() {

		let rememberWordsNumber = vocabularyStore.numberOfWordsFrom(
			FetchRequestFactory.fetchRequest(for: .remembering, wordCollectionID: currentWordCollectionID)
		)
		let repeatWordsNumber = vocabularyStore.numberOfWordsFrom(
			FetchRequestFactory.fetchRequest(for: .repetition, wordCollectionID: currentWordCollectionID)
		)
		let remindWordsNumber = vocabularyStore.numberOfWordsFrom(
			FetchRequestFactory.fetchRequest(for: .reminding, wordCollectionID: currentWordCollectionID)
		)

		learningOptionsView.viewData = LearningOptionsView.ViewData(
			rememberWordsNumber: rememberWordsNumber,
			repeatWordsNumber: repeatWordsNumber,
			remindWordsNumber: remindWordsNumber
		)
	}
}

extension LearningOptionsViewController: CurrentWordCollectionInfoObserver {

	func currentWordCollectionDidChange(_ wordCollectionInfo: WordCollectionInfo?) {
		navigationItem.title = "\(wordCollectionInfo?.name ?? "Vocabulary")"
		updateLearningOptionsView()
	}
}

