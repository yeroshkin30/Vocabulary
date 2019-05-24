//
//	ListOfWordsDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 9/28/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class ListOfWordsDataSource: NSObject {
	
	var learningStage: Word.LearningStage?	{ didSet { predicateParameterDidChange() } }
	var searchQuery: String?				{ didSet { predicateParameterDidChange() } }
	
	weak var delegate: NSFetchedResultsControllerDelegate?
	
	private let context: NSManagedObjectContext
	
	init(context: NSManagedObjectContext) {
		self.context = context
	}
	
	private var parameters: WordsRequestParameter {
		return (learningStage, currentWordCollection, false)
	}
	
	private lazy var fetchedResultsController = initializeFetchedResultsController()
	
	func wordAt(_ indexPath: IndexPath) -> Word {
		return fetchedResultsController.object(at: indexPath)
	}
}

// MARK: - Private -
private extension ListOfWordsDataSource {
	
	var currentPredicate: NSPredicate {
		let predicate = FetchRequestFactory.predicateForWords(with: parameters)
		
		if let query = searchQuery {
			let format = "\(#keyPath(Word.headword)) BEGINSWITH[cd] %@"
			let searchPredicate = NSPredicate(format: format, query)
			
			return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, searchPredicate])
		}
		return predicate
	}
	
	func initializeFetchedResultsController() -> NSFetchedResultsController<Word> {
		let request = FetchRequestFactory.requestForWords(with: parameters)
		request.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(Word.dateCreated), ascending: false)
		]
		
		let controller = NSFetchedResultsController(fetchRequest: request,
													managedObjectContext: context,
													sectionNameKeyPath: nil,
													cacheName: nil)
		controller.delegate = delegate
		try? controller.performFetch()
		return controller
	}
	
	func predicateParameterDidChange() {
		fetchedResultsController.fetchRequest.predicate = currentPredicate
		try? fetchedResultsController.performFetch()
	}
}

// MARK: - UITableViewDataSource -
extension ListOfWordsDataSource: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		let word = fetchedResultsController.object(at: indexPath)
		
		cell.textLabel?.text = word.headword
		cell.detailTextLabel?.text = word.sentencePart
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
}
