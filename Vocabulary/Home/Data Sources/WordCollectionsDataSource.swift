//
//	WordCollectionsDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 5/7/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class WordCollectionsDataSource: NSObject {
	
	weak var delegate: NSFetchedResultsControllerDelegate?
	
	private let context: NSManagedObjectContext
	
	init(context: NSManagedObjectContext) {
		self.context = context
	}
	
	private var parameters: WordsRequestParameters {
		return (nil, currentWordCollectionInfo?.objectID, false)
	}
	
	private lazy var fetchedResultsController = initializeFetchedResultsController()
	
	private func initializeFetchedResultsController() -> NSFetchedResultsController<WordCollection> {
		let wordCollectionRequest = WordCollection.createFetchRequest()
		wordCollectionRequest.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(WordCollection.dateCreated), ascending: false)
		]
		let controller = NSFetchedResultsController(fetchRequest: wordCollectionRequest,
													managedObjectContext: context,
													sectionNameKeyPath: nil, cacheName: nil)
		controller.delegate = delegate
		try? controller.performFetch()
		return controller
	}
	
	func wordCollection(_ indexPath: IndexPath) -> WordCollection {
		return fetchedResultsController.object(at: indexPath)
	}
	
	func indexPath(for wordCollection: WordCollection) -> IndexPath? {
		return fetchedResultsController.indexPath(forObject: wordCollection)
	}
}

// MARK: - UITableViewDataSource -
extension WordCollectionsDataSource: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ??	0
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
		
		let allWordsNumber = wordCollection.words?.count ?? 0
		let unknownWordsNumber = (try? context.count(for: fetchRequest)) ?? 0
		
		cell.textLabel?.text = wordCollection.name
		cell.detailTextLabel?.text = cellDetailTextFor(
			allWordsNumber: allWordsNumber, unknownWordsNumber: unknownWordsNumber
		)
		cell.accessoryType = currentWordCollectionInfo?.objectID == wordCollection.objectID
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
