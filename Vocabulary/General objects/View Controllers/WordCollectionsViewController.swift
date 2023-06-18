//
//	WordCollectionsViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 7/3/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class WordCollectionsViewController: UITableViewController, SegueHandlerType {

	// MARK: - Initialization

	let vocabularyStore: VocabularyStore
	private let modelController: WordCollectionsModelController

	init?(coder: NSCoder, vocabularyStore: VocabularyStore, modelController: WordCollectionsModelController) {
		self.vocabularyStore = vocabularyStore
		self.modelController = modelController

		super.init(coder: coder)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Actions

	@IBAction
	private func doneButtonDidTap() {
		dismiss(animated: true)
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		modelController.dataChangesHandler = { [unowned self] changes in
			self.tableView.handleChanges(changes)
		}

		tableView.dataSource = modelController
		vocabularyStore.viewContext.undoManager = UndoManager()
	}
	
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		showUndoAlert()
	}

	// MARK: - Navigation

	enum SegueIdentifier: String {
		case createCollection, renameCollection
	}

	@IBSegueAction
	private func makeInputTextViewController(
		coder: NSCoder,
		sender: Any?,
		segueIdentifier: String?
	) -> InputTextViewController? {

		guard
			let identifier: String = segueIdentifier,
			let segue: SegueIdentifier = SegueIdentifier(rawValue: identifier) else {
				return nil
		}

		switch segue {
		case .createCollection:
			return InputTextViewController(coder: coder, title: "New word collection", charactersCapacity: .verySmall) {
				[unowned self] (name) in

				self.modelController.createWordCollection(withName: name)
			}
		case .renameCollection:
			guard
				let cell: UITableViewCell = sender as? UITableViewCell,
				let indexPath: IndexPath = tableView.indexPath(for: cell) else {
					return nil
			}

			let initialText: String = modelController.wordCollectionAt(indexPath).name

			return InputTextViewController(
				coder: coder,
				title: "Rename",
				initialText: initialText,
				charactersCapacity: .verySmall
			) { [unowned self] (newName) in

				self.modelController.renameWordCollection(at: indexPath, with: newName)
			}
		}
	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		modelController.selectWordCollection(at: indexPath)

		dismiss(animated: true)
	}
	
	override func tableView(_ tableView: UITableView,
							trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
	) -> UISwipeActionsConfiguration? {

		let renameAction: UIContextualAction = .init(
			style: .normal,
			title: "Rename") { (_, _, handler) in
				self.performSegue(with: .renameCollection, sender: tableView.cellForRow(at: indexPath))
				handler(true)
		}

		let deleteAction: UIContextualAction = .init(
			style: .destructive,
			title: "Delete") { (_, _, handler) in
				let wordCollectionToDelete: WordCollection = self.modelController.wordCollectionAt(indexPath)

				let fetchRequest: NSFetchRequest<Word> = WordFetchRequestFactory.requestForWords(from: wordCollectionToDelete)
				let numberOfWordsToDelete: Int = self.vocabularyStore.numberOfWordsFrom(fetchRequest)

				if numberOfWordsToDelete == 0 {
					self.modelController.deleteWordCollection(at: indexPath)
					handler(true)
				} else {
					self.showDeleteWordCollectionAlert(at: indexPath)
					handler(false)
				}
		}

		return UISwipeActionsConfiguration(actions: [deleteAction, renameAction])
	}
}

// MARK: - Private -
private extension WordCollectionsViewController {
	
	func showDeleteWordCollectionAlert(at indexPath: IndexPath) {
		let wordCollection: WordCollection = modelController.wordCollectionAt(indexPath)
		
		let title: String = "Delete \"\(wordCollection.name)\" collection?"

		let alert: UIAlertController = .init(title: title, message: nil, preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Collection and Words", style: .destructive) { (_) in
			self.modelController.deleteWordCollection(at: indexPath)
		})
		alert.addAction(UIAlertAction(title: "Only Collection", style: .destructive) { (_) in
			self.modelController.deleteWordCollection(at: indexPath, withWords: false)
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		present(alert, animated: true, completion: nil)
	}
}
