//
//  WordCollectionsModelController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 24.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class WordCollectionsModelController: NSObject {

	var dataChangesHandler: (([FetchedDataChange]) -> Void)?

	private let vocabularyStore: VocabularyStore
	private let currentWordCollectionModelController: CurrentWordCollectionModelController

	init(vocabularyStore: VocabularyStore, currentWordCollectionModelController: CurrentWordCollectionModelController) {
		self.vocabularyStore = vocabularyStore
		self.currentWordCollectionModelController = currentWordCollectionModelController

		super.init()
	}

	private lazy var fetchedResultsController: NSFetchedResultsController = initializeFetchedResultsController()

	private var dataChanges: [FetchedDataChange] = []

	private var currentWordCollectionID: NSManagedObjectID? {
		return currentWordCollectionModelController.wordCollectionInfo?.objectID
	}

	// MARK: - Public methods

	func wordCollectionAt(_ indexPath: IndexPath) -> WordCollection {
		return fetchedResultsController.object(at: indexPath)
	}

	func selectWordCollection(at indexPath: IndexPath) {
		let wordCollection = fetchedResultsController.object(at: indexPath)

		if wordCollection.objectID == currentWordCollectionID {
			currentWordCollectionModelController.wordCollectionInfo = nil

		} else {
			currentWordCollectionModelController.wordCollectionInfo = WordCollectionInfo(wordCollection)
		}
	}

	func deleteWordCollection(at indexPath: IndexPath, withWords deleteWords: Bool = true) {
		let wordCollection = fetchedResultsController.object(at: indexPath)

		if deleteWords, let words = wordCollection.words as? Set<Word> {
			words.forEach { vocabularyStore.viewContext.delete($0) }
		}
		if wordCollection.objectID == currentWordCollectionModelController.wordCollectionInfo?.objectID {
			currentWordCollectionModelController.wordCollectionInfo = nil
		}
		vocabularyStore.deleteObject(wordCollection)
	}

	func renameWordCollection(at indexPath: IndexPath, with newName: String) {
		let wordCollection = fetchedResultsController.object(at: indexPath)

		wordCollection.name = newName
		if wordCollection.objectID == currentWordCollectionModelController.wordCollectionInfo?.objectID {
			currentWordCollectionModelController.wordCollectionInfo = WordCollectionInfo(wordCollection)
		}
		vocabularyStore.saveChanges()
	}

	func createWordCollection(withName name: String) {
		let wordCollection = WordCollection(context: vocabularyStore.viewContext)
		wordCollection.name = name

		vocabularyStore.saveChanges()
	}
}

// MARK: - Private
private extension WordCollectionsModelController {

	func initializeFetchedResultsController() -> NSFetchedResultsController<WordCollection> {
		let wordCollectionRequest = WordCollection.createFetchRequest()
		wordCollectionRequest.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(WordCollection.dateCreated), ascending: false)
		]
		let controller = NSFetchedResultsController(
			fetchRequest: wordCollectionRequest,
			managedObjectContext: vocabularyStore.viewContext,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		controller.delegate = self
		try? controller.performFetch()
		return controller
	}


}

// MARK: - UITableViewDataSource
extension WordCollectionsModelController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		let wordCollection = fetchedResultsController.object(at: indexPath)
		configureCell(cell, for: wordCollection)
		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	private func configureCell(_ cell: UITableViewCell, for wordCollection: WordCollection) {
		let parameters: WordsRequestParameters = (.unknown, wordCollection.objectID, false)
		let fetchRequest = FetchRequestFactory.requestForWords(with: parameters)

		#warning("number from context")
		let allWordsNumber = wordCollection.words?.count ?? 0
		let unknownWordsNumber = vocabularyStore.numberOfWordsFrom(fetchRequest)

		cell.textLabel?.text = wordCollection.name
		cell.detailTextLabel?.text = cellDetailTextFor(
			allWordsNumber: allWordsNumber, unknownWordsNumber: unknownWordsNumber
		)
		cell.accessoryType = currentWordCollectionID == wordCollection.objectID
			? .checkmark : .none
	}

	private func cellDetailTextFor(allWordsNumber: Int, unknownWordsNumber: Int) -> String {
		switch (allWordsNumber, unknownWordsNumber) {
		case (0, _):
			return "Empty"
		case (_, 0):
			return "Remembered"
		case _ where allWordsNumber == unknownWordsNumber:
			return "All words are unknown (\(allWordsNumber))"
		default:
			return "\(unknownWordsNumber) of \(allWordsNumber) are unknown"
		}
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension WordCollectionsModelController: NSFetchedResultsControllerDelegate {

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any, at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		dataChanges.append((type, indexPath, newIndexPath))
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		dataChangesHandler?(dataChanges)
		dataChanges = []
	}
}
