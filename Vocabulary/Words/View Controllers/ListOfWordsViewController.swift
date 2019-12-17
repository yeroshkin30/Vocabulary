//
//	ListOfWordsViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/6/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

class ListOfWordsViewController: UITableViewController, SegueHandlerType {

	// MARK: - Initialization

	let vocabularyStore: VocabularyStore
	private let learningStage: Word.LearningStage?
	private let currentWordCollectionID: NSManagedObjectID?

	init?(
		coder: NSCoder,
		vocabularyStore: VocabularyStore,
		learningStage: Word.LearningStage?,
		currentWordCollectionID: NSManagedObjectID?
	) {
		self.vocabularyStore = vocabularyStore
		self.learningStage = learningStage
		self.currentWordCollectionID = currentWordCollectionID

		super.init(coder: coder)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Public properties -
	
	var dataChanges: [DataChange] = []
	
	// MARK: - Outlets -
	
	@IBOutlet private var editButton: UIBarButtonItem!

	@IBOutlet private var createButton: UIBarButtonItem!
	@IBOutlet private var moveButton: UIBarButtonItem!
	@IBOutlet private var selectAllButton: UIBarButtonItem!
	@IBOutlet private var deleteButton: UIBarButtonItem!
	
	@IBOutlet private var leftFlexibleSpace: UIBarButtonItem!
	@IBOutlet private var rightFlexibleSpace: UIBarButtonItem!
	
	// MARK: - Private properties -
	
	private let searchController = UISearchController(searchResultsController: nil)
	
	private lazy var wordsDataSource = ListOfWordsDataSource(
		context: vocabularyStore.context, learningStage: learningStage, currentWordCollectionID: currentWordCollectionID
	)
	
	private lazy var editingToolbarItems: [UIBarButtonItem] = [
		moveButton, leftFlexibleSpace, selectAllButton, rightFlexibleSpace, deleteButton
	]
	
	private lazy var defaultToolbarItems: [UIBarButtonItem] = [
		leftFlexibleSpace, createButton, rightFlexibleSpace
	]
	
	private var needShowEditingToolbarButtons = true
	
	private var editingWordIndexPath: IndexPath?
	
	// MARK: - Life Cycle -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initialConfiguration()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		navigationController?.setToolbarHidden(false, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		stopPronouncing()
		navigationController?.setToolbarHidden(true, animated: false)
	}
	
	override var textInputContextIdentifier: String? {
		return ListOfWordsViewController.stringIdentifier
	}
	
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		showUndoAlert()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		editButton.title = editing ? "Done" : "Edit"
		updateToolBar()
	}
	
	// MARK: - Navigation -
	
	enum SegueIdentifier: String {
		case editWord, createWord, moveWords
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let navigationController = segue.destination as! UINavigationController
		
		switch segueIdentifier(for: segue) {
		case .createWord, .editWord:
			let viewController = navigationController.viewControllers.first as! EditWordViewController
			viewController.delegate = self
			
			if let indexPath = editingWordIndexPath {
				let word = wordsDataSource.wordAt(indexPath)
				viewController.viewData = EditWordViewController.ViewData(word: word)
			}
			
		case .moveWords:
			let viewController = navigationController.viewControllers.first as! WordDestinationsViewController
			viewController.destinationHandler = handle(_:)
			viewController.vocabularyStore = vocabularyStore
		}
	}
}

// MARK: - Actions -
private extension ListOfWordsViewController {
	
	@IBAction func closeButtonAction() {
		searchController.isActive = false
		dismiss(animated: true)
	}
	
	@IBAction func selectAllButtonAction(_ sender: UIBarButtonItem) {
		if isAllCellsSelected {
			deselectAllCells()
		} else {
			selectAllCells()
		}
		updateToolBar()
	}
	
	@IBAction func editButtonAction(_ sender: UIBarButtonItem) {
		setEditing(!isEditing, animated: true)
	}
	
	@IBAction func deleteWordsButtonAction(_ sender: UIBarButtonItem) {
		guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
		
		deleteWords(at: indexPaths)
		setEditing(false, animated: true)
	}
	
	@IBAction func pronounceButtonAction(_ sender: UIButton) {
		guard let indexPath = tableView.indexPathForRow(with: sender) else { return }
		let word = wordsDataSource.wordAt(indexPath).headword
		pronounce(word)
	}
}

// MARK: - Configuration -
private extension ListOfWordsViewController {

	func initialConfiguration() {
		vocabularyStore.context.undoManager = UndoManager()

		wordsDataSource.delegate = self
		tableView.dataSource = wordsDataSource

		configureSearchController()
		configureNavigationBar()
		updateToolBar()
	}
	
	func configureNavigationBar() {
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.searchController = searchController
		
		navigationItem.title = learningStage?.name ?? "All Words"
	}
	
	func configureSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.searchBar.placeholder = "Seaech by headword"
		searchController.searchResultsUpdater = self
		definesPresentationContext = true
	}
	
	func updateToolBar() {
		if isEditing && needShowEditingToolbarButtons {
			toolbarItems = editingToolbarItems
			
			let hasSelectedRows = (tableView.indexPathForSelectedRow?.count ?? 0) > 0
			
			let wordsNumber = tableView.numberOfRows(inSection: 0)
			selectAllButton.isEnabled = wordsNumber > 0
			moveButton.isEnabled = hasSelectedRows
			deleteButton.isEnabled = hasSelectedRows
		} else {
			toolbarItems = defaultToolbarItems
		}
		selectAllButton.title = isAllCellsSelected ? "Deselect All" : "Select All"
	}
}

// MARK: - Helpers -
private extension ListOfWordsViewController {
	
	func deleteWords(at indexPaths: [IndexPath]) {
		indexPaths.forEach {
			let word = wordsDataSource.wordAt($0)
			vocabularyStore.context.delete(word)
		}
		vocabularyStore.saveChanges()
	}
	
	func handle(_ destination: WordDestinationsViewController.Destination) {
		guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
		
		switch destination {
		case .learningStage(let stage):
			indexPaths.forEach {
				wordsDataSource.wordAt($0).learningStage = stage
			}
		case .wordCollection(let wordCollection):
			let words = indexPaths.compactMap { wordsDataSource.wordAt($0) }
			wordCollection.addToWords(NSSet(array: words))
		}
		setEditing(false, animated: true)
		vocabularyStore.saveChanges()
	}
}

// MARK: - Cells Selection -
private extension ListOfWordsViewController {
	
	var isAllCellsSelected: Bool {
		let wordsNumber = tableView.numberOfRows(inSection: 0)
		let selectedCellsNumber = tableView.indexPathsForSelectedRows?.count ?? 0
		return selectedCellsNumber > 0 && selectedCellsNumber == wordsNumber
	}
	
	func selectAllCells() {
		let wordsNumber = tableView.numberOfRows(inSection: 0)
		
		for index in 0..<wordsNumber {
			let indexPath = IndexPath(row: index, section: 0)
			tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
		}
	}
	
	func deselectAllCells() {
		guard let selectedCellIndexPaths = tableView.indexPathsForSelectedRows else { return }
		
		for indexPath in selectedCellIndexPaths {
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
}

// MARK: - UITableViewDelegate -
extension ListOfWordsViewController {
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		updateToolBar()
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		updateToolBar()
	}
	
	override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		needShowEditingToolbarButtons = false
		super.tableView(tableView, willBeginEditingRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		needShowEditingToolbarButtons = true
		super.tableView(tableView, didEndEditingRowAt: indexPath)
	}
	
	override func tableView(
		_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
		) -> UISwipeActionsConfiguration? {
		
		let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, handler) in
			self.editingWordIndexPath = indexPath
			self.performSegue(with: .editWord, sender: nil)
			handler(true)
		}
		
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, handler) in
			let word = self.wordsDataSource.wordAt(indexPath)
			self.vocabularyStore.deleteObject(word)
			handler(true)
		}
		
		return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
	}
}

// MARK: - UISearchResultsUpdating -
extension ListOfWordsViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		if let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty {
			wordsDataSource.searchQuery = searchQuery
		} else {
			wordsDataSource.searchQuery = nil
		}
		tableView.reloadData()
	}
}

// MARK: - EditWordViewControllerDelegate -
extension ListOfWordsViewController: EditWordViewControllerDelegate {
	
	func editWordViewController(_ viewController: EditWordViewController,
										didFinishWith action: EditWordViewController.ResultAction) {		
		switch action {
		case .save:
			vocabularyStore.context.undoManager?.beginUndoGrouping()
			if let indexPath = editingWordIndexPath {
				let word = wordsDataSource.wordAt(indexPath)
				fill(word, with: viewController.viewData)
				
			} else {
				let word = Word(context: vocabularyStore.context)
				fill(word, with: viewController.viewData)
			}
			vocabularyStore.context.undoManager?.endUndoGrouping()
			
		case .delete:
			if let indexPath = editingWordIndexPath {
				let word = wordsDataSource.wordAt(indexPath)
				vocabularyStore.context.delete(word)
			}
			
		case .cancel:
			break
		}
		
		editingWordIndexPath = nil
		vocabularyStore.saveChanges()
		viewController.dismiss(animated: true)
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension ListOfWordsViewController: FetchedResultsTableViewControllerDelegate {
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any, at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		dataChanges.append((type, indexPath, newIndexPath))
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		handleWordsChanges()
	}
}
