//
//	ConstructHeadwordController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/2/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol ConstructHeadwordControllerDelegate: AnyObject {
	func constructHeadwordController(_ controller: ConstructHeadwordController,
									didSelectLetter letter: String)
	func constructionDidComplete(by controller: ConstructHeadwordController)
}

class ConstructHeadwordController: NSObject, HeadwordInputViewProvider {
	
	weak var delegate: ConstructHeadwordControllerDelegate?
	
	// MARK: - HeadwordInputController
	
	var headword: String? { didSet { headwordDidChange() } }
	
	var inputView: UIView {
		return constructHeadwordInputView
	}
	
	func restart() {
		headwordDidChange()
	}
	
	private lazy var constructHeadwordInputView = initializeCollectionView()
	
	private var headwordLetters: [String: Int] = [:]
	private var numberOfShownItems = 0
	
	private let maxSectionsNumber = 3
	private let maxItemsInSectionNumber = 5
	
	private let itemSpacing: CGFloat = 0
	
	private lazy var itemSide: CGFloat = {
		let sectionWidth = UIScreen.main.bounds.width * 0.9
		let entireInteritemSpacing: CGFloat = itemSpacing * CGFloat(maxItemsInSectionNumber - 1)
		let spaceForAllItems: CGFloat = sectionWidth - entireInteritemSpacing
		return spaceForAllItems / CGFloat(maxItemsInSectionNumber)
	}()
}

// MARK: - Helpers
private extension ConstructHeadwordController {
	
	func headwordDidChange() {
		headwordLetters = [:]
		parseHeadword()
		numberOfShownItems = 0
		constructHeadwordInputView.reloadData()
	}
	
	func initializeCollectionView() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = itemSpacing
		layout.minimumInteritemSpacing = itemSpacing
		layout.itemSize = CGSize(width: itemSide, height: itemSide)
		
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView.autoresizingMask = [.flexibleHeight]
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.backgroundColor = .clear
		
		collectionView.registerNibForCell(LetterCollectionViewCell.self)
		
		return collectionView
	}
	
	func parseHeadword() {
		guard let headword = headword else {
			headwordLetters = [:]
			return
		}
		
		for letter in headword.lowercased() {
			if let count = headwordLetters["\(letter)"] {
				headwordLetters["\(letter)"] = count + 1
			} else {
				headwordLetters["\(letter)"] = 1
			}
		}
	}
	
	func dataForFirstItem() -> LetterCollectionViewCell.LetterItemData {
		let letter = String(headword!.first!).lowercased()
		let lettersNumber = headwordLetters[letter]
		
		headwordLetters.removeValue(forKey: letter)
		
		return (letter, lettersNumber!)
	}
	
	func randomDataForItem() -> LetterCollectionViewCell.LetterItemData? {
		guard !headwordLetters.isEmpty else { return nil }
		
		let randomIndex = Int.random(in: 0..<headwordLetters.count)
		
		let letter = Array(headwordLetters.keys)[randomIndex]
		let lettersNumber = headwordLetters[letter]
		
		headwordLetters.removeValue(forKey: letter)
		
		return (letter, lettersNumber!)
	}
}

// MARK: - UICollectionViewDataSource
extension ConstructHeadwordController: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		let currentNumberOfLetters = headwordLetters.count
		let maxItemsNumber = maxSectionsNumber * maxItemsInSectionNumber
		
		if currentNumberOfLetters > maxItemsNumber {
			return maxSectionsNumber
			
		} else {
			let difference = maxItemsNumber - currentNumberOfLetters
			return maxSectionsNumber - (difference / maxItemsInSectionNumber)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		
		let availableItemsNumber = maxItemsInSectionNumber * (section + 1)
		let difference = availableItemsNumber - headwordLetters.count
		return difference < 0 ? maxItemsInSectionNumber : maxItemsInSectionNumber - difference
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueCell(indexPath: indexPath) as LetterCollectionViewCell
		
		cell.isHidden = false
		
		if indexPath == IndexPath.first {
			cell.letterItemData = dataForFirstItem()
		} else {
			cell.letterItemData = randomDataForItem()!
		}
		numberOfShownItems += 1
		return cell
	}
}

// MARK: - UICollectionViewDelegate
extension ConstructHeadwordController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView,
						willDisplay cell: UICollectionViewCell,
						forItemAt indexPath: IndexPath) {
		
		if let cell = cell as? LetterCollectionViewCell {
			cell.updateCornerRadius()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView,
						shouldSelectItemAt indexPath: IndexPath) -> Bool {
		
		if let cell = collectionView.cellForItem(at: indexPath) {
			return !cell.isHidden
		}
		return false
	}
	
	func collectionView(_ collectionView: UICollectionView,
						didUnhighlightItemAt indexPath: IndexPath) {
		
		guard let cell = collectionView.cellForItem(at: indexPath) as? LetterCollectionViewCell,
			let itemData = cell.letterItemData
			else { return }
		
		delegate?.constructHeadwordController(self, didSelectLetter: itemData.letter)
		
		if itemData.number == 1 {
			if let newItemData = randomDataForItem() {
				cell.letterItemData = newItemData
			} else {
				cell.isHidden = true
				numberOfShownItems -= 1
			}
		} else {
			let newItemData = (itemData.letter, itemData.number - 1)
			cell.letterItemData = newItemData
		}
		
		if numberOfShownItems == 0 {
			delegate?.constructionDidComplete(by: self)
		}
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ConstructHeadwordController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		
		let numberOfSections = CGFloat(self.numberOfSections(in: collectionView))
		let numberOfItems = CGFloat(self.collectionView(collectionView,
														numberOfItemsInSection: section))
		
		let height = collectionView.bounds.height
		let allCellsHeight = itemSide * numberOfSections
		let verticalSpace = ((height - allCellsHeight) / (numberOfSections + 1)).rounded(.down)
		
		let width = collectionView.bounds.width
		let sectionWidth = numberOfItems * itemSide + (itemSpacing * (numberOfItems - 1))
		let horizontalSpace = ((width - sectionWidth) / 2).rounded(.down)
		
		return UIEdgeInsets.init(top: verticalSpace, left: horizontalSpace, bottom: 0, right: horizontalSpace)
	}
}
