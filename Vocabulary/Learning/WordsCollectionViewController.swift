//
//  WordsCollectionViewController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 4/9/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class WordsCollectionViewController: UIViewController {
	
	// MARK: - Public properties
	
	var coreDataService: CoreDataService!
	
	var fetchRequest: NSFetchRequest<Word> {
		return Word.createFetchRequest()
	}
	
	lazy var wordsDataSource = initializeFetchedResultsController()
	
	var backgroundMessageView: BackgroundMessageView? { return nil }
	
	// MARK: - Outlet properties
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
	
	// MARK: - Private properties
	
	private var itemsChanges: [ItemChange] = []
	
	private struct ItemChange {
		let change: NSFetchedResultsChangeType
		let from: IndexPath?
		let to: IndexPath?
	}
	
	// MARK: - Life cycle
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		collectionView.backgroundView = nil
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		stopPronouncing()
	}
	
	// MARK: - Helpers
	
	func configureCell(_ cell: WordCollectionViewCell, for indexPath: IndexPath) {
		let word = wordsDataSource.object(at: indexPath)
		cell.viewData = WordCollectionViewCell.ViewData(word: word)
	}
	
	private func initializeFetchedResultsController() -> NSFetchedResultsController<Word> {
		
		let controller: NSFetchedResultsController<Word>
		
		controller = NSFetchedResultsController(fetchRequest: fetchRequest,
												managedObjectContext: coreDataService.context,
												sectionNameKeyPath: nil, cacheName: nil)
		do {
			try controller.performFetch()
		} catch {
			fatalError("Failed to initialize FetchedResultsController: \(error)")
		}
		controller.delegate = self
		return controller
	}
}

// MARK: - UICollectionViewDataSource
extension WordsCollectionViewController: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return wordsDataSource.sections?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		let sectionInfo = wordsDataSource.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueCell(indexPath: indexPath) as WordCollectionViewCell
		
		configureCell(cell, for: indexPath)
		
		return cell
	}
}

// MARK: - UICollectionViewDelegate
extension WordsCollectionViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
						forItemAt indexPath: IndexPath) {
		
		if wordsDataSource.fetchedObjects?.isEmpty ?? true {
			collectionView.backgroundView = backgroundMessageView
		}
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WordsCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	var itemWidth: CGFloat {
		let screenWidth = UIScreen.main.bounds.width
		return screenWidth * 0.85
	}
	
	var itemHeight: CGFloat {
		let screenHeight = UIScreen.main.bounds.height
		return screenHeight * 0.72
	}
	
	var gorizontalInset: CGFloat {
		return (UIScreen.main.bounds.width - itemWidth) / 2
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: itemWidth, height: itemHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		
		let topInset: CGFloat = 20.0
		let bottomInset = collectionView.bounds.height - itemHeight - topInset
		
		return UIEdgeInsetsMake(topInset, gorizontalInset, bottomInset, gorizontalInset)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		
		return gorizontalInset * 2
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension WordsCollectionViewController: NSFetchedResultsControllerDelegate {
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any, at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		
		itemsChanges.append(ItemChange(change: type, from: indexPath, to: newIndexPath))
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		collectionView?.performBatchUpdates({
			for itemChange in itemsChanges {
				switch itemChange.change {
				case .insert:
					collectionView.backgroundView = nil
					collectionView?.insertItems(at: [itemChange.to!])
				case .delete:
					collectionView?.deleteItems(at: [itemChange.from!])
				case .move:
					collectionView?.moveItem(at: itemChange.from!, to: itemChange.to!)
				case .update:
					collectionView?.reloadItems(at: [itemChange.from!])
				}
			}
			itemsChanges.removeAll()
		}, completion: nil)
	}
}
