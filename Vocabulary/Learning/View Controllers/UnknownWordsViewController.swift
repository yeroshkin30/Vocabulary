//
//	UnknownWordsViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 2/18/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

final class UnknownWordsViewController: BaseWordsLearningViewController, SegueHandlerType {
	
	// MARK: - Private properties
	
	private var wordsToRemember: [Word] = []
	
	private let maxNumberOfWordsToRemembering = 5
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		initialProgressValue = min(numberOfWords, maxNumberOfWordsToRemembering)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if numberOfWords == 0 || !wordsToRemember.isEmpty {
			navigationController?.popViewController(animated: false)
		}
	}
	
	// MARK: - BaseWordsLearningViewController -
	
	override func instantiateDataSource(with words: [Word]) -> WordsLearningCollectionViewDataSource {
		let fetchRequest = FetchRequestFactory.fetchRequest(for: .remembering, wordCollectionID: currentWordCollectionID)
		let words = vocabularyStore.wordsFrom(fetchRequest)
		return UnknownWordsCollectionViewDataSource(words: words)
	}
	
	override func updateProgressView() {
		
		let newProgress = Float(wordsToRemember.count) / Float(initialProgressValue)
		progressView.setProgress(newProgress, animated: true)
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								willDisplay cell: UICollectionViewCell,
								forItemAt indexPath: IndexPath) {
		super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
		
		if let cell = cell as? FullCardCollectionViewCell {
			cell.cellActionHandler = { [weak self] action in
				self?.handleCellAction(action)
			}
		}
	}
	
	// MARK: - Segue Types
	
	enum SegueIdentifier: String {
		case startRemembering
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
		case .startRemembering:
			
			let navVC = segue.destination as! UINavigationController
			let viewController = navVC.viewControllers.first as! LearningProcessViewController
			viewController.vocabularyStore = vocabularyStore
			viewController.learningMode = .remembering(wordsToRemember)
		}
	}
}

// MARK: - Private -
private extension UnknownWordsViewController {
	
	func startRememberingIfNeeds() {
		if numberOfWords == 0 || wordsToRemember.count == maxNumberOfWordsToRemembering {
			performSegue(with: .startRemembering, sender: nil)
		}
	}
	
	func handleCellAction(_ action: FullCardCollectionViewCell.Action) {
		guard let word = dataSource.currentWord else { return }
		
		switch action {
		case .negative:
			word.nextTrainingDate = Date()
			dataSource.collectionView(collectionView, reactToAnswerImpact: .negative)
			vocabularyStore.saveChanges()
			
		case .single, .positive:
			wordsToRemember.append(word)
			dataSource.collectionView(collectionView, reactToAnswerImpact: .positive)
			updateProgressView()
			startRememberingIfNeeds()
			
		case .pronounce:
			pronounce(word.headword)
		}
	}
}
