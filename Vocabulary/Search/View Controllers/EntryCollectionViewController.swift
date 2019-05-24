//
//	EntryCollectionViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 12/25/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class EntryCollectionViewController: UICollectionViewController, DefinitionsRequestProvider, SegueHandlerType {
	
	var entry: Entry!
	var vocabularyStore: VocabularyStore!
	
	// MARK: - DefinitionsRequestProvider -
	
	var wordToRequest: String?
	
	// MARK: - Outlets -
	
	@IBOutlet private var viewModeSegmentedControl: UISegmentedControl!
	@IBOutlet private var addToLearningButton: UIBarButtonItem!
	
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
	
	// MARK: - Life cicle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupCollectionView()
		setupSegmentControl()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isToolbarHidden = false
		navigationItem.title = entry.headword
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.isToolbarHidden = true
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
			let viewController = editWordNavController.viewControllers.first as! CollectWordDataViewController
			
			viewController.delegate = self
			
			if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
				viewController.viewData = wordDataForDefinition(at: indexPath)
			}
			
			addToLearningButton.isEnabled = false
		}
	}
	
	// MARK: - UICollectionViewDelegate -
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		if let cell = collectionView.cellForItem(at: indexPath), cell.isSelected {
			collectionView.deselectItem(at: indexPath, animated: true)
			addToLearningButton.isEnabled = false
			return false
		}
		addToLearningButton.isEnabled = true
		return true
	}
}

// MARK: - Helpers
private extension EntryCollectionViewController {
	
	func setupCollectionView() {
		collectionView?.dataSource = dataSource
		
		if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
			let width = UIScreen.main.bounds.size.width
			layout.estimatedItemSize = CGSize(width: width, height: 100)
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
		addToLearningButton.isEnabled = false
		
		dataSource = EntryCollectionViewDataSource(entry: entry, viewMode: viewMode)
		
		collectionView?.dataSource = dataSource
		collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
		collectionView?.reloadData()
	}
	
	func wordDataForDefinition(at indexPath: IndexPath) -> CollectWordDataViewController.ViewData {
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
		
		return CollectWordDataViewController.ViewData(headword: headword,
													  sentencePart: entry.sentencePart,
													  definition: definition.text,
													  examples: definition.examples,
													  mode: .create)
	}
}

// MARK: - Types -
extension EntryCollectionViewController {
	enum ViewMode: Int {
		case definitions, expressions
	}
}

// MARK: - EditWordViewControllerDelegate -
extension EntryCollectionViewController: CollectWordDataViewControllerDelegate {
	
	func collectWordDataViewController(_ viewController: CollectWordDataViewController,
										didFinishWith action: CollectWordDataViewController.ResultAction) {
		
		switch action {
		case .save:
			let word = Word(context: vocabularyStore.context)
			fill(word, with: viewController.viewData)
			vocabularyStore.saveChanges()
			navigationController?.popViewController(animated: true)
			
		default: break
		}
		viewController.dismiss(animated: true)
	}
}
