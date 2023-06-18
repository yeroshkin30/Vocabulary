//
//  ListOfWordsModelController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 24.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class ListOfWordsModelController: NSObject {

	var dataChangesHandler: (([FetchedDataChange]) -> Void)?

	private let vocabularyStore: VocabularyStore
	let learningStage: Word.LearningStage?
	private let currentWordCollectionID: NSManagedObjectID?

	init(
		vocabularyStore: VocabularyStore,
		learningStage: Word.LearningStage?,
		currentWordCollectionID: NSManagedObjectID?
	) {
		self.vocabularyStore = vocabularyStore
		self.learningStage = learningStage
		self.currentWordCollectionID = currentWordCollectionID
	}

	private lazy var fetchedResultsController = initializeFetchedResultsController()
	private var dataChanges: [FetchedDataChange] = []

	// MARK: - Public methods

	func wordAt(_ indexPath: IndexPath) -> Word {
		return fetchedResultsController.object(at: indexPath)
	}

	func deleteWords(at indexPaths: [IndexPath]) {
		indexPaths.forEach {
			let word: Word = fetchedResultsController.object(at: $0)
			vocabularyStore.viewContext.delete(word)
		}
		vocabularyStore.saveChanges()
	}

	func moveWords(at indexPaths: [IndexPath], to destination: WordDestinationsViewController.Destination) {
		switch destination {
		case .learningStage(let stage):
			indexPaths.forEach {
				let word: Word = fetchedResultsController.object(at: $0)
				word.learningStage = stage
			}
		case .wordCollection(let wordCollection):
			let words = indexPaths.compactMap { fetchedResultsController.object(at: $0) }
			wordCollection.addToWords(NSSet(array: words))
		}
		vocabularyStore.saveChanges()
	}

	func filterWordsBy(searchQuery query: String?) {
		let parameters: WordsRequestParameters = (learningStage, currentWordCollectionID, false)

		var predicate = WordFetchRequestFactory.predicateForWords(with: parameters)

		if let query = query {
			let format = "\(#keyPath(Word.headword)) BEGINSWITH[cd] %@"
			let searchPredicate = NSPredicate(format: format, query)

			predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, searchPredicate])
		}

		fetchedResultsController.fetchRequest.predicate = predicate
		try? fetchedResultsController.performFetch()
	}
}

// MARK: - Private
private extension ListOfWordsModelController {

	func initializeFetchedResultsController() -> NSFetchedResultsController<Word> {
		let request = WordFetchRequestFactory.requestForWords(with: (learningStage, currentWordCollectionID, false))
		request.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(Word.dateCreated), ascending: false)
		]

		let controller = NSFetchedResultsController(
			fetchRequest: request,
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
extension ListOfWordsModelController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		let word: Word = fetchedResultsController.object(at: indexPath)

		cell.textLabel?.text = word.headword
		cell.detailTextLabel?.text = word.sentencePart
		cell.accessoryView?.isHidden = tableView.isEditing

		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension ListOfWordsModelController: NSFetchedResultsControllerDelegate {

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
