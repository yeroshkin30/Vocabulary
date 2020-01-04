//
//	RemindWordsViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/8/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

final class RemindWordsViewController: BaseWordsLearningViewController {
	
	// MARK: - Private properties
	
	private let recommendedRemindingNumber = 5
	
	private var currentCell: RemindWordCollectionViewCell? {
		return collectionView.cellForItem(at: IndexPath.first) as? RemindWordCollectionViewCell
	}
	
	private lazy var endRemindingMessageView: MessageView = {
		let view: MessageView = MessageView.instantiate()
		view.message = MessageView.Message(
			title: "Excellent!", text: "You were reminded all available words.", actionTitle: "Back",
			actionClosure: { [weak self] in
				self?.navigationController?.popViewController(animated: true)
		})
		return view
	}()
	
	// MARK: - BaseWordsLearningViewController -
	
	override func instantiateDataSource(with words: [Word]) -> WordsLearningCollectionViewDataSource {
		let fetchRequest = WordFetchRequestFactory.fetchRequest(for: .reminding, wordCollectionID: currentWordCollectionID)
		let words = vocabularyStore.wordsFrom(fetchRequest)
		return RemindWordsCollectionViewDataSource(words: words)
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
	
	func collectionView(_ collectionView: UICollectionView,
						didEndDisplaying cell: UICollectionViewCell,
						forItemAt indexPath: IndexPath) {
		
		if numberOfWords == 0 {
			collectionView.backgroundView = endRemindingMessageView
		}
	}
}

// MARK: - Private -
private extension RemindWordsViewController {
	
	func completeWordReminding() {
		vocabularyStore.saveChanges()
		dataSource.collectionView(collectionView, reactToAnswerImpact: .positive)
		updateProgressView()
	}
	
	func handleCellAction(_ action: FullCardCollectionViewCell.Action) {
		guard let word = dataSource.currentWord else { return }
		
		switch action {
		case .single:		completeWordReminding()
		case .positive:	handlePositiveAction()
		case .pronounce:	pronounce(word.headword)
		case .negative:
			word.decreaseLearningStage()
			
			if let cell = currentCell {
				cell.optionsMode = .oneOption
			}
		}
	}
	
	func handlePositiveAction() {
		guard let word = dataSource.currentWord else { return }
		
		if case .numberOfReminders(let number) = word.learningStageDetail,
			number >= recommendedRemindingNumber {
			
			showStopRemindingSuggestion(for: word, withRemindsNumber: number)
			
		} else {
			word.increaseLearningStage()
			completeWordReminding()
		}
	}
	
	func showStopRemindingSuggestion(for word: Word, withRemindsNumber number: Int) {
		
		let title = "Mark as learned?"
		let message = """
		You were reminded \"\(word.headword)\" \(number) times.
		Do you want to mark it as learned or you want to keep on reminding?
		"""
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Remind", style: .cancel, handler: { (_) in
			word.increaseLearningStage()
			self.completeWordReminding()
		}))
		alert.addAction(UIAlertAction(title: "Mark", style: .default, handler: { (_) in
			word.learningStage = .learned
			self.completeWordReminding()
		}))
		
		present(alert, animated: true, completion: nil)
	}
}
