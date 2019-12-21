//
//	VocabularyStore.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/26/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import CoreData

private let modelFileName = "Vocabulary"

class VocabularyStore: NSPersistentContainer {

	init(name: String = modelFileName) {
		guard let model = NSManagedObjectModel.mergedModel(from: nil) else {
			fatalError("Can't load managed object models from bundle")
		}
		super.init(name: name, managedObjectModel: model)

		loadPersistentStores(completionHandler: { (_, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		viewContext.mergePolicy = NSOverwriteMergePolicy
	}

	static var isPersistentStoreEmpty: Bool {
		let location = NSPersistentContainer.defaultDirectoryURL()
		let content = try? FileManager.default.contentsOfDirectory(at: location, includingPropertiesForKeys: nil)

		return content?.isEmpty == true
	}

	static func loadDefaultVocabulary() {
		let location = NSPersistentContainer.defaultDirectoryURL()

		let fm = FileManager.default

		let fileExtensions = ["sqlite", "sqlite-shm", "sqlite-wal"]

		for fileExtension in fileExtensions {
			if let source = Bundle.main.url(forResource: modelFileName, withExtension: fileExtension) {
				let destination = location.appendingPathComponent(source.lastPathComponent)
				try? fm.copyItem(at: source, to: destination)
			}
		}
	}
	
	func saveChanges() {
		guard viewContext.hasChanges else { return }
		do {
			try viewContext.save()
		} catch let error {
			fatalError("Unable to save with error: \(error.localizedDescription)")
		}
	}

	func deleteObject(_ managedObject: NSManagedObject) {
		viewContext.delete(managedObject)
		saveChanges()
	}
	
	func numberOfWordsFrom(_ fetchRequest: NSFetchRequest<Word>) -> Int {
		do {
			return try viewContext.count(for: fetchRequest)
		} catch let error {
			fatalError("Unable to count words with error: \(error.localizedDescription)")
		}
	}
	
	func wordsFrom(_ fetchRequest: NSFetchRequest<Word>) -> [Word] {
		do {
			return try viewContext.fetch(fetchRequest)
		} catch let error {
			fatalError("Unable to fetch words with error: \(error.localizedDescription)")
		}
	}
}
