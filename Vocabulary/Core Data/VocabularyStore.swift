//
//	VocabularyStore.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/26/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import CoreData
import UIKit

fileprivate(set) var currentWordCollection: WordCollection?

class VocabularyStore {
	
	var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	private lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Vocabulary")
		container.loadPersistentStores(completionHandler: { (_, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		container.viewContext.mergePolicy = NSOverwriteMergePolicy
		return container
	}()
	
	func saveChanges() {
		guard context.hasChanges else { return }
		do {
			try context.save()
		} catch let error {
			fatalError("Unable to save with error: \(error.localizedDescription)")
		}
	}
	
	func discardChanges() {
		guard context.hasChanges else { return }
		context.rollback()
	}
	
	func deleteAndSave(_ word: Word) {
		context.delete(word)
		saveChanges()
	}
	
	func deleteAndSave(_ wordCollection: WordCollection) {
		context.delete(wordCollection)
		saveChanges()
	}
	
	func numberOfWordsFrom(_ fetchRequest: NSFetchRequest<Word>) -> Int {
		do {
			return try context.count(for: fetchRequest)
		} catch let error {
			fatalError("Unable to count words with error: \(error.localizedDescription)")
		}
	}
	
	func wordsFrom(_ fetchRequest: NSFetchRequest<Word>) -> [Word] {
		do {
			return try context.fetch(fetchRequest)
		} catch let error {
			fatalError("Unable to fetch words with error: \(error.localizedDescription)")
		}
	}
}

extension VocabularyStore: WordCollectionsTableViewControllerDelegate {
	func wordCollectionsTableViewController(_ controller: WordCollectionsTableViewController,
											didSelect wordCollection: WordCollection?) {
		currentWordCollection = wordCollection
	}
}
