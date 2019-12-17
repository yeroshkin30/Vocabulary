//
//	BaseWordsLearningViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/24/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData.NSManagedObjectID

class BaseWordsLearningViewController: UIViewController {
	
	// MARK: - Public properties
	
	var vocabularyStore: VocabularyStore!
	var currentWordCollectionID: NSManagedObjectID?
	
	var numberOfWords: Int {
		return dataSource.questionsNumber
	}
	
	var initialProgressValue = 0 { didSet { updateProgressView() } }
	
	lazy var dataSource = instantiateDataSource(with: [])
	
	// MARK: - Outlet Properties -
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var progressView: UIProgressView!
	
	@IBOutlet var autoPronounceButton: UIButton!
	
	// MARK: - Actions -
	
	@IBAction private func autoPronounceButtonAction(_ sender: UIButton) {
		autoPronounceButtonTapped()
	}
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.dataSource = dataSource
		initialProgressValue = numberOfWords
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		stopPronouncing()
	}
	
	func instantiateDataSource(with words: [Word]) -> WordsLearningCollectionViewDataSource {
		return BaseWordsLearningCollectionViewDataSource(words: [])
	}
	
	func updateProgressView() {
		let currentProgress = initialProgressValue - numberOfWords
		let newProgress = Float(currentProgress) / Float(initialProgressValue)
		progressView.setProgress(newProgress, animated: true)
	}
	
	func autoPronounceButtonTapped() {
		if autoPronounceButton.isSelected {
			stopPronouncing()
		}
		autoPronounceButton.isSelected.toggle()
	}
}

// MARK: - UICollectionViewDelegate
extension BaseWordsLearningViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView,
						willDisplay cell: UICollectionViewCell,
						forItemAt indexPath: IndexPath) {
		
		if autoPronounceButton.isSelected, let word = dataSource.currentWord {
			pronounce(word.headword)
		}
	}
}
