//
//	RememberWordsCollectionViewDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/25/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class RememberWordsCollectionViewDataSource: NSObject {
	
	private let rememberingStagesNumber = 3
	
	private var wordSections: [[Word]] = []
	
	init(words: [Word]) {
		for _ in 1...rememberingStagesNumber {
			let sectionWords = words.shuffled()
			wordSections.append(sectionWords)
		}
	}
}

// MARK: - LearnWordsCollectionViewDataSource
extension RememberWordsCollectionViewDataSource: WordsLearningCollectionViewDataSource {
	
	var questionsNumber: Int {
		return wordSections.reduce(0) { $0 + $1.count }
	}
	
	var currentWord: Word? {
		guard let word = wordSections.first?.first else {
			return nil
		}
		
		let sectionsNumber = wordSections.count
		
		if sectionsNumber == 3 {
			word.learningStageDetail = .select
		} else if sectionsNumber == 2 {
			word.learningStageDetail = .construct
		} else {
			word.learningStageDetail = .input
		}
		
		return word
	}
	
	func collectionView(_ collectionView: UICollectionView,
						reactToAnswerImpact impact: AnswerImpact) {
		switch impact {
		case .positive:
			handleCorrectAnswer(in: collectionView)
		case .negative:
			handleIncorrectAnswer(in: collectionView)
		}
	}
	
	// MARK: - UICollectionViewDataSource
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return questionsNumber > 0 ? 1 : 0
	}
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return questionsNumber
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueCell(indexPath: indexPath) as LearningCollectionViewCell
		
		let word = wordSections.flatMap{ $0 }[indexPath.item]
		cell.viewData = LearningCollectionViewCell.ViewData(word: word)
		
		return cell
	}
}

// MARK: - Private -
private extension RememberWordsCollectionViewDataSource {
	
	func handleCorrectAnswer(in collectionView: UICollectionView) {
		guard var currentWordSection = wordSections.first else { return }
		
		if currentWordSection.count == 1 {
			wordSections.removeFirst()
		} else {
			currentWordSection.removeFirst()
			wordSections[0] = currentWordSection
		}
		
		if wordSections.isEmpty {
			collectionView.deleteSections(IndexSet(integer: 0))
		} else {
			collectionView.deleteItems(at: [IndexPath.first])
		}
	}
	
	func handleIncorrectAnswer(in collectionView: UICollectionView) {
		guard var currentWordSection = wordSections.first else { return }
		
		if currentWordSection.count == 1 {
			collectionView.reloadItems(at: [IndexPath.first])
		} else {
			let word = currentWordSection.removeFirst()
			currentWordSection.append(word)
			wordSections[0] = currentWordSection
			
			let indexPath = IndexPath(item: currentWordSection.count - 1, section: 0)
			
			collectionView.performBatchUpdates({
				collectionView.deleteItems(at: [IndexPath.first])
				collectionView.insertItems(at: [indexPath])
			})
		}
	}
}
