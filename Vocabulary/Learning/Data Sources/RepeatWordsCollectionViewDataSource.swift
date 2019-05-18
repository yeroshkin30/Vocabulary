//
//	RepeatWordsCollectionViewDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/26/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class RepeatWordsCollectionViewDataSource: BaseWordsLearningCollectionViewDataSource {
	
	override func collectionView(_ collectionView: UICollectionView,
						reactToAnswerImpact impact: AnswerImpact) {
		
		words.removeFirst()
		
		if questionsNumber > 0 {
			collectionView.deleteItems(at: [IndexPath.first])
		} else {
			collectionView.deleteSections(IndexSet(integer: 0))
		}
	}
	
	// MARK: - UICollectionViewDataSource

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return words.isEmpty ? 0 : 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueCell(indexPath: indexPath) as LearningCollectionViewCell
		cell.viewData = LearningCollectionViewCell.ViewData(word: words[indexPath.item])
		return cell
	}
	
}
