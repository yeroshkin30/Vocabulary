//
//	WordDestinationsViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/15/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class WordDestinationsViewController: UITableViewController {

	// MARK: - Initialization

	private let vocabularyStore: VocabularyStore
	private let destinationHandler: ((Destination) -> Void)

	init?(coder: NSCoder, vocabularyStore: VocabularyStore, destinationHandler: @escaping ((Destination) -> Void)) {

		self.vocabularyStore = vocabularyStore
		self.destinationHandler = destinationHandler
		super.init(coder: coder)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Outlets
	
	@IBOutlet private weak var saveButton: UIBarButtonItem!
	
	// MARK: - Private properties
	
	private lazy var wordCollections: [WordCollection] = {
		let wordCollectionsFetchRequest = WordCollection.createFetchRequest()
		wordCollectionsFetchRequest.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(WordCollection.lastSelectedDate), ascending: false),
			NSSortDescriptor(key: #keyPath(WordCollection.dateCreated), ascending: true)
		]
		return (try? vocabularyStore.viewContext.fetch(wordCollectionsFetchRequest)) ?? []
	}()
	
	private lazy var viewData = ViewData(wordCollections: wordCollections)
	
	// MARK: - Actions
	
	@IBAction private func saveButtonAction(_ sender: UIBarButtonItem) {
		guard let indexPath = tableView.indexPathForSelectedRow else { return }
		
		switch ViewData.Section(at: indexPath) {
		case .learningStages:
			let stage = Word.LearningStage(rawValue: Int16(indexPath.row))!
			destinationHandler(.learningStage(stage))
			
		case .wordCollections:
			let wordCollection = wordCollections[indexPath.row]
			destinationHandler(.wordCollection(wordCollection))
		}
		
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction private func cancelButtonAction(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.tableFooterView = UIView()
	}
	
	// MARK: - UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewData.numberOfSections
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewData.numberOfCells(in: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		cell.textLabel?.text = viewData.textOfCell(at: indexPath)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return viewData.sectionTitle(for: section)
	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		cell?.accessoryType = .checkmark
		
		saveButton.isEnabled = true
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)
		cell?.accessoryType = .none
	}
}

extension WordDestinationsViewController {
	
	enum Destination {
		case wordCollection(WordCollection)
		case learningStage(Word.LearningStage)
	}
	
	struct ViewData {
		
		enum Section: Int {
			case learningStages, wordCollections
			
			init(at indexPath: IndexPath) {
				self = Section.init(rawValue: indexPath.section)!
			}
			
			init(_ section: Int) {
				self = Section.init(rawValue: section)!
			}
		}
		
		private let wordCollections: [WordCollection]
		
		init(wordCollections: [WordCollection]) {
			self.wordCollections = wordCollections
		}
		
		var numberOfSections: Int {
			return wordCollections.isEmpty ? 1 : 2
		}
		
		func numberOfCells(in section: Int) -> Int {
			switch Section(section) {
			case .learningStages:
				return Word.LearningStage.count
			case .wordCollections:
				return wordCollections.count
			}
		}
		
		func sectionTitle(for section: Int) -> String {
			switch Section(section) {
			case .learningStages:	return "Learning stages"
			case .wordCollections:	return "Word collections"
			}
		}
		
		func textOfCell(at indexPath: IndexPath) -> String {
			switch Section(at: indexPath) {
			case .learningStages:
				return Word.LearningStage.names[indexPath.row]
			case .wordCollections:
				return wordCollections[indexPath.row].name
			}
		}
	}
}
