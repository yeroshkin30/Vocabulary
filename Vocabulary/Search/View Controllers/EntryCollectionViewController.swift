//
//	EntryCollectionViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 12/25/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData.NSManagedObjectID

class EntryCollectionViewController: UICollectionViewController, DefinitionsRequestProvider, SegueHandlerType {

	// MARK: - Initialization

	private let vocabularyStore: VocabularyStore
	private let entry: Entry
	private let currentWordCollectionID: NSManagedObjectID?

	init?(coder: NSCoder, vocabularyStore: VocabularyStore, entry: Entry, currentWordCollectionID: NSManagedObjectID?) {
		self.vocabularyStore = vocabularyStore
		self.entry = entry
		self.currentWordCollectionID = currentWordCollectionID
		super.init(coder: coder)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - DefinitionsRequestProvider -
	
	var wordToRequest: String?
	
	// MARK: - Outlets -
	
	@IBOutlet private var viewModeSegmentedControl: UISegmentedControl!
	
	// MARK: - Private properties
	
	private var viewMode: ViewMode = .definitions { didSet { viewModeDidChange() }}
	
	private lazy var dataSource = EntryCollectionViewDataSource(entry: entry, viewMode: viewMode)
	
	// MARK: - Actions
	
	@IBAction private func switchViewModeAction(_ sender: UISegmentedControl) {
		viewMode = ViewMode(rawValue: sender.selectedSegmentIndex)!
	}
	
	@IBAction private func pronounceButtonAction(_ sender: UIButton) {
		pronounce(entry.headword)
	}
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = entry.headword
		setupCollectionView()
		setupSegmentControl()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		stopPronouncing()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
			collectionView?.deselectItem(at: indexPath, animated: false)
		}
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case addToLearning, requestDefinitions
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
		case .requestDefinitions:
			if let button = sender as? UIButton {
				wordToRequest = button.title(for: .normal)
			}

		case .addToLearning:
			let editWordNavController = segue.destination as! UINavigationController
			let viewController = editWordNavController.viewControllers.first as! EditWordViewController
			
			viewController.delegate = self
			
			if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
				viewController.viewData = wordDataForDefinition(at: indexPath)
				collectionView.deselectItem(at: indexPath, animated: true)
			}
		}
	}
}

// MARK: - Helpers
private extension EntryCollectionViewController {
	
	func setupCollectionView() {
		collectionView?.dataSource = dataSource

		if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
			let width = UIScreen.main.bounds.size.width * 0.9
			layout.estimatedItemSize = CGSize(width: width, height: 150.0)
			layout.itemSize = UICollectionViewFlowLayout.automaticSize
		}
	}

	func setupSegmentControl() {
		if entry.definitions.isEmpty {
			viewMode = .expressions
			viewModeSegmentedControl.selectedSegmentIndex = viewMode.rawValue
			viewModeSegmentedControl.setEnabled(false, forSegmentAt: ViewMode.definitions.rawValue)
		}
		if entry.expressions.isEmpty {
			viewMode = .definitions
			viewModeSegmentedControl.selectedSegmentIndex = viewMode.rawValue
			viewModeSegmentedControl.setEnabled(false, forSegmentAt: ViewMode.expressions.rawValue)
		}
	}
	
	func viewModeDidChange() {
		dataSource = EntryCollectionViewDataSource(entry: entry, viewMode: viewMode)
		
		collectionView?.dataSource = dataSource
		collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
		collectionView?.reloadData()
	}
	
	func wordDataForDefinition(at indexPath: IndexPath) -> EditWordViewController.ViewData {
		let headword: String
		let definition: Definition
		
		switch viewMode {
		case .definitions:
			headword = entry.headword
			definition = entry.definitions[indexPath.item]
		case .expressions:
			let expression = entry.expressions[indexPath.section]
			
			headword = expression.text
			definition = expression.definitions[indexPath.item]
		}
		
		return EditWordViewController.ViewData(
			headword: headword,
			sentencePart: entry.sentencePart,
			definition: definition.text,
			examples: definition.examples,
			mode: .create
		)
	}
}

// MARK: - Types -
extension EntryCollectionViewController {

	enum ViewMode: Int {
		case definitions, expressions
	}
}

// MARK: - EditWordViewControllerDelegate -
extension EntryCollectionViewController: EditWordViewControllerDelegate {
	
	func editWordViewController(_ viewController: EditWordViewController,
										didFinishWith action: EditWordViewController.ResultAction) {
		
		switch action {
		case .save:
			let word = Word(context: vocabularyStore.context)
			fill(word, with: viewController.viewData)
			if let objectID = currentWordCollectionID {
				word.wordCollection = vocabularyStore.context.object(with: objectID) as? WordCollection
			}
			vocabularyStore.saveChanges()
			navigationController?.popViewController(animated: true)
			
		default: break
		}
		viewController.dismiss(animated: true)
	}
}
