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
	
	// MARK: - DefinitionsRequestProvider
	
	var wordToRequest: String?
	
	// MARK: - Outlets

	@IBOutlet private var layout: UICollectionViewFlowLayout!
	@IBOutlet private var viewModeSegmentedControl: UISegmentedControl!
	
	// MARK: - Private properties
	
	private var viewMode: ViewMode = .definitions { didSet { viewModeDidChange() }}
	private var viewData: ViewData {
		switch viewMode {
		case .definitions: return definitionsViewData
		case .expressions: return expressionsViewData
		}
	}

	private lazy var definitionsViewData = ViewData(entry: entry, viewMode: .definitions)
	private lazy var expressionsViewData = ViewData(entry: entry, viewMode: .expressions)
	
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

		initialSetup()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		stopPronouncing()
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case addToLearning, requestDefinitions
	}

	@IBSegueAction
	private func makeEditWordViewController(coder: NSCoder, sender: Any?, segueIdentifier: String?) -> EditWordViewController? {
		guard let cell = sender as? UICollectionViewCell,
			let indexPath = collectionView.indexPath(for: cell)
		else { return nil }

		let editWordContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		editWordContext.parent = vocabularyStore.viewContext

		let word = Word(context: vocabularyStore.viewContext)
		word.fill(with: entry, viewMode: viewMode, at: indexPath)
		if let objectID = currentWordCollectionID {
			word.wordCollection = editWordContext.object(with: objectID) as? WordCollection
		}

		let editedWord = editWordContext.object(with: word.objectID) as! Word

		return EditWordViewController(coder: coder, context: editWordContext, word: editedWord) { [unowned self] (action) in
			self.handleEditing(of: word, withResultAction: action)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
		case .requestDefinitions:
			if let button = sender as? UIButton {
				wordToRequest = button.title(for: .normal)
			}
		default:
			break
		}
	}
}

// MARK: - UICollectionViewDataSource
extension EntryCollectionViewController {

	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return viewData.numberOfSections
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewData.numberOfItems(inSection: section)
	}

	override func collectionView(_ collectionView: UICollectionView,
								 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueCell(indexPath: indexPath) as DefinitionCollectionViewCell
		let definition = viewData.definitionData(for: indexPath)
		cell.viewData = DefinitionCollectionViewCell.ViewData(definition: definition)
		return cell
	}

	override func collectionView(_ collectionView: UICollectionView,
								 viewForSupplementaryElementOfKind kind: String,
								 at indexPath: IndexPath) -> UICollectionReusableView {

		let view = collectionView.dequeueSupplementaryView(of: kind, at: indexPath) as DefinitionsCollectionViewHeader
		view.viewData = viewData.sectionViewData(for: indexPath.section)
		return view
	}
}

// MARK: - Helpers
private extension EntryCollectionViewController {

	var headerSize: CGSize {
		let height: CGFloat = viewMode == .definitions ? 25.0 : 50.0
		return CGSize(width: collectionView.bounds.width, height: height)
	}

	func initialSetup() {
		navigationItem.title = entry.headword
		viewMode =  entry.definitions.isEmpty ? .expressions : .definitions

		setupCollectionView()
		setupSegmentControl()
	}
	
	func setupCollectionView() {
		let width = collectionView.bounds.width * 0.9
		layout.estimatedItemSize = CGSize(width: width, height: 150.0)
		layout.itemSize = UICollectionViewFlowLayout.automaticSize
		layout.headerReferenceSize = headerSize
	}

	func setupSegmentControl() {
		viewModeSegmentedControl.selectedSegmentIndex = viewMode.rawValue
		viewModeSegmentedControl.setEnabled(!entry.definitions.isEmpty, forSegmentAt: ViewMode.definitions.rawValue)
		viewModeSegmentedControl.setEnabled(!entry.expressions.isEmpty, forSegmentAt: ViewMode.expressions.rawValue)
	}

	func viewModeDidChange() {
		layout.headerReferenceSize = headerSize
		collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
		collectionView?.reloadData()
	}

	func handleEditing(of word: Word, withResultAction action: EditWordViewController.ResultAction) {
		switch action {
		case .save:
			vocabularyStore.saveChanges()
			navigationController?.popViewController(animated: true)
		case .delete, .cancel:
			vocabularyStore.deleteObject(word)
		}
	}
}

// MARK: - Types
extension EntryCollectionViewController {

	enum ViewMode: Int {
		case definitions, expressions
	}

	struct ViewData {
		typealias SectionIndex = Int
		typealias HeaderViewData = DefinitionsCollectionViewHeader.ViewData

		private let sections: [HeaderViewData]
		private let items: [SectionIndex: [Definition]]

		init(entry: Entry, viewMode: EntryCollectionViewController.ViewMode) {

			switch viewMode {
			case .definitions:
				sections = [HeaderViewData(entry: entry)]
				items = [0: entry.definitions]

			case .expressions:
				var _sections: [HeaderViewData] = []
				var _items: [SectionIndex: [Definition]] = [:]

				entry.expressions.enumerated().forEach { (index, expression) in
					_sections.append(HeaderViewData(expression: expression))
					_items[index] = expression.definitions
				}
				sections = _sections
				items = _items
			}
		}

		var numberOfSections: Int { sections.count }

		func numberOfItems(inSection section: Int) -> Int 			{ items[section]?.count ?? 0 }
		func sectionViewData(for section: Int) -> HeaderViewData	{ sections[section] }
		func definitionData(for indexPath: IndexPath) -> Definition { items[indexPath.section]![indexPath.item] }
	}
}

// MARK: - EditWordViewController
fileprivate extension Word {

	func fill(with entry: Entry, viewMode: EntryCollectionViewController.ViewMode, at indexPath: IndexPath) {
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

		self.headword = headword
		self.sentencePart = entry.sentencePart
		self.definition	= definition.text
		self.examples	= definition.examples
	}
}
