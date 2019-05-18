//
//	UnknownWordsCollectionViewDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/24/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

final class UnknownWordsCollectionViewDataSource: BaseWordsLearningCollectionViewDataSource {
	
	override func collectionView(_ collectionView: UICollectionView,
								reactToAnswerImpact impact: AnswerImpact) {
		guard !words.isEmpty else { return }
		
		let word = words.removeFirst()
		
		switch impact {
		case .negative:
			words.append(word)
			
			collectionView.performBatchUpdates({
				collectionView.deleteItems(at: [IndexPath.first])
				collectionView.insertItems(at: [IndexPath(item: words.count - 1, section: 0)])
			}, completion: nil)
						
		case .positive:
			collectionView.deleteItems(at: [IndexPath.first])
		}
	}
	
	// MARK: - UICollectionViewDataSource -
	
	override func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueCell(indexPath: indexPath) as FullCardCollectionViewCell
		
		let word = words[indexPath.item]
		cell.viewData = FullCardCollectionViewCell.ViewData(word: word)
		
		if words.count == 1 { cell.optionsMode = .oneOption }
		
		return cell
	}
}
