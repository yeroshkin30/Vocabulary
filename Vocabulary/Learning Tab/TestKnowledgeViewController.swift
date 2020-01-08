//
//  FlashCardsViewController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 4/8/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class TestKnowledgeViewController: WordsCollectionViewController {
	
	// MARK: - Outlet properties
	
	@IBOutlet private weak var progressView: UIProgressView!
	
	// MARK: - Private properties
	
	private var currentQuestion: FlashCardQuestion = .first
	
	private var totalProggres = 1
	private var currentProgress = 0 {
		didSet {
			let progress = Float(currentProgress) / Float(totalProggres)
			progressView.setProgress(progress, animated: true)
		}
	}
	
	// MARK: - Types
	
	private enum FlashCardQuestion: String {
		case first = "Mark as learned?"
		case second = "Mark as unknown?"
	}
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		totalProggres = wordsDataSource.fetchedObjects?.count ?? 1
		currentProgress = 0
	}
	
	// MARK: - Overriden
	
	override var fetchRequest: NSFetchRequest<Word> {
		let fetchRequest = coreDataService.wordsFetchRequesAt(learningStage: .test,
															  from: coreDataService.selectedSetOfWords,
															  considerNextTrainingDate: true)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Word.nextTrainingDate),
														 ascending: true)]
		return fetchRequest
	}
	
	override var backgroundMessageView: BackgroundMessageView {
		let nib = UINib(nibName: BackgroundMessageView.nibName, bundle: nil)
		let messageView = nib.instantiate(withOwner: nil,
										  options: nil).first as! BackgroundMessageView
		messageView.delegate = self
		
		messageView.title = "Excellent!"
		messageView.message = "You checked all available words."
		messageView.utilityButtonsTytle = "Back"
		return messageView
	}
	
	override func configureCell(_ cell: WordCollectionViewCell, for indexPath: IndexPath) {
		super.configureCell(cell, for: indexPath)
		
		if let cell = cell as? TestKnowledgeCollectionViewCell {
			cell.questionText = currentQuestion.rawValue
			cell.delegate = self
		}
	}
	
	// MARK: - Helpers
	
	private func setupWord(_ word: Word, withQuestionConfirmence confirmed: Bool) {
		
		switch (currentQuestion, confirmed){
		case (.first, true):
			word.trainingStage.up()
		case (.second, true):
			word.trainingStage = .untrained
		case (_, false):
			word.updateNextTrainingDate()
		}
		currentProgress += 1
		currentQuestion = .first
		coreDataService.saveChanges()
	}
}

// MARK: - FlashCardCollectionViewCellDelegate
extension TestKnowledgeViewController: TestKnowledgeCollectionViewCellDelegate {
	
	func pronounceButtonTapped(in cell: TestKnowledgeCollectionViewCell) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		
		let word = wordsDataSource.object(at: indexPath)
		pronounce(word.headword)
	}
	
	func definitionShown(in cell: TestKnowledgeCollectionViewCell) {
		currentQuestion = .second
		cell.questionText = currentQuestion.rawValue
	}
	
	func questionConfirmed(in cell: TestKnowledgeCollectionViewCell) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		
		let word = wordsDataSource.object(at: indexPath)
		
		setupWord(word, withQuestionConfirmence: true)
	}
	
	func questionDenyed(in cell: TestKnowledgeCollectionViewCell) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		
		let word = wordsDataSource.object(at: indexPath)
		
		setupWord(word, withQuestionConfirmence: false)
	}
}

// MARK: - BackgroundMessageViewDelegate
extension TestKnowledgeViewController: BackgroundMessageViewDelegate {
	
	func utilityButtonDidTapped() {
		navigationController?.popViewController(animated: true)
	}
}
