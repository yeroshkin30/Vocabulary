//
//	RememberingCompletionViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/12/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class RememberingCompletionViewController: UICollectionViewController {
	
	var learnedWords: [Word] = []
	
	// MARK: - Actions
	
	@IBAction private func doneButtonAction(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.setHidesBackButton(true, animated: false)
		
		if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
			layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		}
	}
	
	// MARK: UICollectionViewDataSource
	
	override func collectionView(_ collectionView: UICollectionView,
								numberOfItemsInSection section: Int) -> Int {
		return learnedWords.count
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueCell(indexPath: indexPath) as RememberingCompletionCollectionViewCell
		
		let word = learnedWords[indexPath.row]
		
		cell.viewData = RememberingCompletionCollectionViewCell.ViewData(word: word)
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								viewForSupplementaryElementOfKind kind: String,
								at indexPath: IndexPath) -> UICollectionReusableView {
		
		let view = collectionView
			.dequeueSupplementaryView(of: kind, at: indexPath) as MessageCollectionViewHeader
		
		let number = learnedWords.count
		
		view.titleText = "Well done!"
		view.messageText = "You have remembered \(number) new word"
		
		if number > 1 {
			view.messageText.append("s")
		}
		
		return view
	}
}
