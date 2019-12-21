//
//	WordCollectionsTableViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 7/3/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class WordCollectionsTableViewController: UITableViewController {

	// MARK: - Initialization

	let vocabularyStore: VocabularyStore
	let currentWordCollectionModelController: CurrentWordCollectionModelController

	init?(
		coder: NSCoder,
		vocabularyStore: VocabularyStore,
		currentWordCollectionModelController: CurrentWordCollectionModelController
	) {
		self.vocabularyStore = vocabularyStore
		self.currentWordCollectionModelController = currentWordCollectionModelController
		super.init(coder: coder)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Public properties -
	
	var dataChanges: [DataChange] = []
	
	// MARK: - Private properties
	
	private lazy var wordCollectionsDataSource = WordCollectionsDataSource(
		context: vocabularyStore.viewContext,
		currentWordCollectionID: currentWordCollectionModelController.wordCollectionInfo?.objectID
	)
	
	private var currentWordCollection: WordCollection? {
		guard let objectID = currentWordCollectionModelController.wordCollectionInfo?.objectID else { return nil }
		return vocabularyStore.viewContext.object(with: objectID) as? WordCollection
	}
	
	private var wordCollectionToRename: WordCollection?

	// MARK: - Actions

	@IBAction
	private func doneButtonDidTap() {
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		wordCollectionsDataSource.delegate = self
		tableView.dataSource = wordCollectionsDataSource
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if vocabularyStore.viewContext.undoManager == nil {
			vocabularyStore.viewContext.undoManager = UndoManager()
		}
	}
	
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		showUndoAlert()
	}
//
//	// MARK: - Navigation
//
//	enum SegueIdentifier: String {
//		case createCollection, renameCollection
//	}
//
//	@IBSegueAction
//	private func makeInputTextViewController(
//		coder: NSCoder, sender: Any?, segueIdentifier: String?
//	) -> InputTextViewController? {
//
//		guard let identifier = segueIdentifier else { return nil }
//
//		switch SegueIdentifier(rawValue: identifier) {
//		case .createCollection:
//			return InputTextViewController(coder: coder, charactersCapacity: .verySmall) { [unowned self] (text) in
//				self.updateNameOfWordCollection(at: nil, with: text)
//			}
//		case .renameCollection:
//			return InputTextViewController(coder: coder, charactersCapacity: .verySmall) { [unowned self] (text) in
//
//				self.updateNameOfWordCollection(at: nil, with: text)
//			}
//		}
//		guard let entries = searchStateModelController.state.resultEntries else { return nil }
//
//		let index = tableView.indexPathForSelectedRow?.row ?? 0
//		let entry = entries[index]
//		let currentWordCollectionID = currentWordCollectionInfoProvider.wordCollectionInfo?.objectID
//
//		return EntryCollectionViewController(
//			coder: coder,
//			vocabularyStore: vocabularyStore,
//			entry: entry,
//			currentWordCollectionID: currentWordCollectionID
//		)
//	}
//
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		switch segueIdentifier(for: segue) {
//		case .createCollection:
//			let viewController = segue.destination as! InputTextViewController
//
//			viewController.delegate = self
//			viewController.initialText = ""
//			viewController.charactersCapacity = .verySmall
//
//		case .renameCollection:
//			guard let wordCollection = wordCollectionToRename else { return }
//
//			let viewController = segue.destination as! InputTextViewController
//
//			viewController.delegate = self
//			viewController.initialText = wordCollection.name
//			viewController.charactersCapacity = .verySmall
//		}
//	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectWordCollection(at: indexPath)
	}
	
//	override func tableView(_ tableView: UITableView,
//							trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
//		) -> UISwipeActionsConfiguration? {
//
//		let renameAction = UIContextualAction(style: .normal,
//											  title: "Rename") { (_, _, handler) in
//			self.wordCollectionToRename = self.wordCollectionsDataSource.wordCollection(indexPath)
//			self.performSegue(with: .renameCollection, sender: nil)
//			handler(true)
//		}
//
//		let deleteAction = UIContextualAction(style: .destructive,
//											  title: "Delete") { (_, _, handler) in
//			let wordCollectionToDelete = self.wordCollectionsDataSource.wordCollection(indexPath)
//
//			if wordCollectionToDelete.words?.count == 0 {
//				self.deleteWordCollection(at: indexPath)
//				handler(true)
//			} else {
//				self.sowAlertForWordCollectionDeletion(at: indexPath)
//				handler(false)
//			}
//		}
//
//		return UISwipeActionsConfiguration(actions: [deleteAction, renameAction])
//	}
}

// MARK: - Private -
private extension WordCollectionsTableViewController {
	
	func selectWordCollection(at indexPath: IndexPath) {
		let selectedWordCollection = wordCollectionsDataSource.wordCollection(indexPath)
		
		if selectedWordCollection == currentWordCollection {
			currentWordCollectionModelController.wordCollectionInfo = nil

		} else {
			currentWordCollectionModelController.wordCollectionInfo = WordCollectionInfo(selectedWordCollection)
		}

		dismiss(animated: true, completion: nil)
	}
	
	func deleteWordCollection(at indexPath: IndexPath) {
		let wordCollection = wordCollectionsDataSource.wordCollection(indexPath)
		
		if currentWordCollection == wordCollection {
			currentWordCollectionModelController.wordCollectionInfo = nil
		}
		vocabularyStore.deleteObject(wordCollection)
	}
	
	func sowAlertForWordCollectionDeletion(at indexPath: IndexPath) {
		let wordCollection = wordCollectionsDataSource.wordCollection(indexPath)
		
		let title = "Delete \"\(wordCollection.name)\" collection?"
		
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Collection and Words", style: .destructive) { (_) in
			if let words = wordCollection.words as? Set<Word> {
				words.forEach { self.vocabularyStore.viewContext.delete($0) }
			}
			self.deleteWordCollection(at: indexPath)
		})
		alert.addAction(UIAlertAction(title: "Only Collection", style: .destructive) { (_) in
			self.deleteWordCollection(at: indexPath)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		present(alert, animated: true, completion: nil)
	}

//	func updateNameOfWordCollection(at indexPath: IndexPath?, with text: String) {
//
//		if let indexPath = indexPath {
//			let wordCollection = wordCollectionsDataSource.wordCollection(indexPath)
//			wordCollection.name = text
//			if wordCollection == currentWordCollection {
//				currentWordCollectionModelController.wordCollectionInfo = WordCollectionInfo(wordCollection)
//			}
//		} else {
//			let newCollection = WordCollection(context: vocabularyStore.viewContext)
//			newCollection.name = text
//		}
//		vocabularyStore.saveChanges()
//		navigationController?.popViewController(animated: true)
//	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension WordCollectionsTableViewController: FetchedResultsTableViewControllerDelegate {
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any, at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		dataChanges.append((type, indexPath, newIndexPath))
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		handleWordsChanges()
	}
}
