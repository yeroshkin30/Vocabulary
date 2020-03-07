//
//	RemindWordsCollectionViewDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/24/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class RemindWordsCollectionViewDataSource: BaseWordsLearningCollectionViewDataSource {
	
	override func collectionView(_ collectionView: UICollectionView,
								reactToAnswerImpact impact: AnswerImpact) {
		
		words.removeFirst()
		collectionView.deleteItems(at: [IndexPath.first])
	}
	
	// MARK: - UICollectionViewDataSource -
	
	override func collectionView(_ collectionView: UICollectionView,
								cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell: RemindWordCollectionViewCell = collectionView.dequeueCell(indexPath: indexPath) as RemindWordCollectionViewCell
		
		let word: Word = words[indexPath.item]
		cell.viewData = FullCardCollectionViewCell.ViewData(word: word)
		cell.optionsMode = .twoOption
		return cell
	}
}
