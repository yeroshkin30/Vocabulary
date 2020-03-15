//
//	BaseWordsLearningCollectionViewDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/25/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

enum AnswerImpact {
	case positive, negative
}

protocol WordsLearningCollectionViewDataSource: UICollectionViewDataSource {
	
	var questionsNumber: Int { get }
	var currentWord: Word? { get }
	
	func collectionView(_ collectionView: UICollectionView, reactToAnswerImpact impact: AnswerImpact)
}

class BaseWordsLearningCollectionViewDataSource: NSObject, WordsLearningCollectionViewDataSource {
	
	var words: [Word]
	
	init(words: [Word]) {
		self.words = words
	}
	
	var questionsNumber: Int {
		return words.count
	}
	
	var currentWord: Word? {
		return words.first
	}
	
	func collectionView(_ collectionView: UICollectionView,
						reactToAnswerImpact impact: AnswerImpact) { }
	
	// MARK: - UICollectionViewDataSource -
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return words.count
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		return UICollectionViewCell(frame: .zero)
	}
}
