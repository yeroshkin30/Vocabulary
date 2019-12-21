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

	@IBOutlet private var moveButton: UIBarButtonItem!
	@IBOutlet private var selectAllButton: UIBarButtonItem!
	@IBOutlet private var deleteButton: UIBarButtonItem!
	
	// MARK: - Private properties -
	
	private let searchController = UISearchController(searchResultsController: nil)
	
	private lazy var wordsDataSource = ListOfWordsDataSource(
		context: vocabularyStore.viewContext, learningStage: learningStage, currentWordCollectionID: currentWordCollectionID
	)
	
	private var needShowEditingToolbarButtons = true
	
	private var editingWordIndexPath: IndexPath?
	
	// MARK: - Life Cycle -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initialConfiguration()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		//		navigationController?.setToolbarHidden(false, animated: true)
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
	}
	
	// MARK: - Navigation -
	
	enum SegueIdentifier: String {
		case editWord, createWord, moveWords
	}

	@IBSegueAction
	private func makeEditWordViewController(coder: NSCoder, sender: Any?, segueIdentifier: String?) -> EditWordViewController? {
		let editWordContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		editWordContext.parent = vocabularyStore.viewContext

		let word: Word

		if let indexPath = editingWordIndexPath {
			word = wordsDataSource.wordAt(indexPath)
		} else {
			word = Word(context: vocabularyStore.viewContext)
		}

		let editedWord = editWordContext.object(with: word.objectID) as! Word

		return EditWordViewController(coder: coder, context: editWordContext, word: editedWord) { [unowned self] (action) in
			self.handleEditing(of: word, withResultAction: action)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let navigationController = segue.destination as! UINavigationController
		
		switch segueIdentifier(for: segue) {
		case .moveWords:
			let viewController = navigationController.viewControllers.first as! WordDestinationsViewController
			viewController.destinationHandler = handle(_:)
			viewController.vocabularyStore = vocabularyStore
			
		default:
			break
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
		updateToolBar()
		navigationController?.setToolbarHidden(isEditing, animated: true)
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
		vocabularyStore.viewContext.undoManager = UndoManager()

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
		searchController.searchBar.placeholder = "Search by headword"
		searchController.searchResultsUpdater = self
		definesPresentationContext = true
	}
	
	func updateToolBar() {
		let hasSelectedRows = (tableView.indexPathForSelectedRow?.count ?? 0) > 0

		let wordsNumber = tableView.numberOfRows(inSection: 0)
		selectAllButton.isEnabled = wordsNumber > 0
		moveButton.isEnabled = hasSelectedRows
		deleteButton.isEnabled = hasSelectedRows
		selectAllButton.title = isAllCellsSelected ? "Deselect All" : "Select All"
	}
}

// MARK: - Helpers -
private extension ListOfWordsViewController {
	
	func deleteWords(at indexPaths: [IndexPath]) {
		indexPaths.forEach {
			let word = wordsDataSource.wordAt($0)
			vocabularyStore.viewContext.delete(word)
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

	func handleWordEditionResultAction(_ action: EditWordViewController.ResultAction) {
		switch action {
		case .save, .delete:
			vocabularyStore.saveChanges()

		case .cancel:
			vocabularyStore.viewContext.undo()
		}
	}


	func handleEditing(of word: Word, withResultAction action: EditWordViewController.ResultAction) {
		switch action {
		case .save, .delete:
			vocabularyStore.saveChanges()

		case .cancel:
			vocabularyStore.viewContext.refresh(word, mergeChanges: false)
		}
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

// MARK: - NSFetchedResultsControllerDelegate
extension ListOfWordsViewController: FetchedResultsTableViewControllerDelegate {
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any, at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		#warning("UITableView was told to layout its visible cells and other contents without being in the view hierarchy")
		dataChanges.append((type, indexPath, newIndexPath))
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		handleWordsChanges()
	}
}
