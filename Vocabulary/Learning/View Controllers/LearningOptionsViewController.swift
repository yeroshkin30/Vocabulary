//
//	LearningOptionsViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/24/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class LearningOptionsViewController: UIViewController, SegueHandlerType {

	// MARK: - Properties -

	@IBOutlet private var learningOptionsView: LearningOptionsView!

	// MARK: - Initialization

	private let vocabularyStore: VocabularyStore

	init?(coder: NSCoder, vocabularyStore: VocabularyStore) {
		self.vocabularyStore = vocabularyStore
		super.init(coder: coder)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLearningOptionsView()
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
private extension LearningOptionsViewController {

	// MARK: - Methods
	
	func setupNotifications() {
		let name = UIApplication.willEnterForegroundNotification
		NotificationCenter.default.addObserver(
			self, selector: #selector(updateLearningOptionsView), name: name, object: nil
		)
	}
	
	func removeNotifications() {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func updateLearningOptionsView() {

		let rememberWordsNumber = vocabularyStore.numberOfWordsFrom(FetchRequestFactory.fetchRequest(for: .remembering))
		let repeatWordsNumber = vocabularyStore.numberOfWordsFrom(FetchRequestFactory.fetchRequest(for: .repetition))
		let remindWordsNumber = vocabularyStore.numberOfWordsFrom(FetchRequestFactory.fetchRequest(for: .reminding))

		learningOptionsView.viewData = LearningOptionsView.ViewData(
			rememberWordsNumber: rememberWordsNumber,
			repeatWordsNumber: repeatWordsNumber,
			remindWordsNumber: remindWordsNumber
		)
	}
}
