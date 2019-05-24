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
	
	// MARK: - Public properties -
	
	var vocabularyStore: VocabularyStore!
	
	var dataChanges: [DataChange] = []
	
	// MARK: - Outlets -
	
	@IBOutlet private var editButton: UIBarButtonItem!
	
	@IBOutlet private var learningStageHeaderButton: UIButton!
	
	@IBOutlet private var createButton: UIBarButtonItem!
	@IBOutlet private var moveButton: UIBarButtonItem!
	@IBOutlet private var selectAllButton: UIBarButtonItem!
	@IBOutlet private var deleteButton: UIBarButtonItem!
	
	@IBOutlet private var leftFlexibleSpace: UIBarButtonItem!
	@IBOutlet private var rightFlexibleSpace: UIBarButtonItem!
	
	// MARK: - Private properties -
	
	private let searchController = UISearchController(searchResultsController: nil)
	
	private lazy var wordsDataSource = ListOfWordsDataSource(context: vocabularyStore.context)
	
	private lazy var learningStagesPopover: ChooseLearningStageViewController = {
		let vc = ChooseLearningStageViewController(style: .plain)
		vc.vocabularyStore = vocabularyStore
		vc.learningStageChangeHandler = { [weak self] stage in
			self?.updateLearinigStage(with: stage)
		}
		return vc
	}()
	
	private lazy var editingTolbarItems: [UIBarButtonItem] = [
		moveButton, leftFlexibleSpace, selectAllButton, rightFlexibleSpace, deleteButton
	]
	
	private lazy var dafaultTolbarItems: [UIBarButtonItem] = [
		leftFlexibleSpace, createButton, rightFlexibleSpace
	]
	
	private var needShowEditingTolbarButtons = true
	
	private var editingWordIndexPath: IndexPath?
	
	// MARK: - Life Cycle -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initialConfiguretion()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isToolbarHidden = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		stopPronouncing()
		navigationController?.isToolbarHidden = true
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
			let viewController = navigationController.viewControllers.first as! CollectWordDataViewController
			viewController.delegate = self
			
			if let indexPath = editingWordIndexPath {
				let word = wordsDataSource.wordAt(indexPath)
				viewController.viewData = CollectWordDataViewController.ViewData(word: word)
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
	
	@IBAction func chooseLearningStageButtonAction(_ sender: UIButton) {
		showLearningStagesPopover()
	}
}

// MARK: - Configuration -
private extension ListOfWordsViewController {
	
	func configureNavigationBar() {
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.searchController = searchController
		
		navigationItem.title = "\(currentWordCollectionInfo?.name ?? "Vocabulary")"
	}
	
	func configureSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.searchBar.placeholder = "Seaech by headword"
		searchController.searchResultsUpdater = self
		definesPresentationContext = true
	}
	
	func initialConfiguretion() {
		vocabularyStore.context.undoManager = UndoManager()
		
		wordsDataSource.delegate = self
		tableView.dataSource = wordsDataSource
		
		configureSearchController()
		configureNavigationBar()
		updateToolBar()
	}
	
	func updateToolBar() {
		if isEditing && needShowEditingTolbarButtons {
			toolbarItems = editingTolbarItems
			
			let hasSelectedRows = (tableView.indexPathForSelectedRow?.count ?? 0) > 0
			
			let wordsNumber = tableView.numberOfRows(inSection: 0)
			selectAllButton.isEnabled = wordsNumber > 0
			moveButton.isEnabled = hasSelectedRows
			deleteButton.isEnabled = hasSelectedRows
		} else {
			toolbarItems = dafaultTolbarItems
		}
		selectAllButton.title = isAllCellsSelected ? "Deselect All" : "Select All"
	}
	
	func updateLearinigStage(with learningStage: Word.LearningStage?) {
		guard wordsDataSource.learningStage != learningStage else { return }
		
		wordsDataSource.learningStage = learningStage
		let learningStageName = learningStage?.name ?? "All Words"
		learningStageHeaderButton.setTitle(learningStageName + " ▼", for: .normal)
		learningStageHeaderButton.sizeToFit()
		tableView.reloadData()
	}
}

// MARK: - Helpers -
private extension ListOfWordsViewController {
	
	func showLearningStagesPopover() {
		let sourceRect = learningStageHeaderButton.bounds
		learningStagesPopover.modalPresentationStyle = .popover
		learningStagesPopover.popoverPresentationController?.sourceView = learningStageHeaderButton
		learningStagesPopover.popoverPresentationController?.sourceRect = sourceRect
		learningStagesPopover.popoverPresentationController?.delegate = self
		
		present(learningStagesPopover, animated: true)
	}
	
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
		needShowEditingTolbarButtons = false
		super.tableView(tableView, willBeginEditingRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		needShowEditingTolbarButtons = true
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
			self.vocabularyStore.deleteAndSave(word)
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
extension ListOfWordsViewController: CollectWordDataViewControllerDelegate {
	
	func collectWordDataViewController(_ viewController: CollectWordDataViewController,
										didFinishWith action: CollectWordDataViewController.ResultAction) {		
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

// MARK: - UIPopoverPresentationControllerDelegate -
extension ListOfWordsViewController: UIPopoverPresentationControllerDelegate {
	
	func adaptivePresentationStyle(
		for controller: UIPresentationController) -> UIModalPresentationStyle {
		
		return UIModalPresentationStyle.none
	}
}
