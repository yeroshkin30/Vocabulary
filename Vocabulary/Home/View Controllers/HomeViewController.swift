//
//	HomeViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 7/5/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, SegueHandlerType {
	
	// MARK: - Private properties
	
	private var vocabularyStore = VocabularyStore()
	
	private lazy var searchDefinitionsViewController = UIStoryboard(storyboard: .home)
		.instantiateViewController() as SearchDefinitionsTableViewController
	
	private lazy var searchController = UISearchController(searchResultsController: nil)
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchDefinitionsViewController.vocabularyStore = vocabularyStore
		setupSearchController()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		vocabularyStore.discardChanges()
		vocabularyStore.context.undoManager = nil
		
		navigationItem.title = "\(currentWordCollection?.name ?? "Vocabulary")"
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case learningTypes, wordCollections, wordCollection
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
		case .learningTypes:
			let viewController = segue.destination as! LearningTypesViewController
			viewController.vocabularyStore = vocabularyStore
			
		case .wordCollections:
			let navVC = segue.destination as! UINavigationController
			let viewController = navVC.viewControllers.first as! WordCollectionsTableViewController
			
			viewController.vocabularyStore = vocabularyStore
			viewController.delegate = vocabularyStore
			
		case .wordCollection:
			let viewController = segue.destination as! ListOfWordsViewController
			viewController.vocabularyStore = vocabularyStore
		}
	}
}

// MARK: - Private -
private extension HomeViewController {
	
	func setupSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.searchBar.placeholder = "Search Definitions"
		searchController.searchBar.autocorrectionType = .yes
		
		searchController.delegate = self
		
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.searchController = searchController
		
		searchDefinitionsViewController.searchBar = searchController.searchBar
	}
}

// MARK: - UISearchControllerDelegate -
extension HomeViewController: UISearchControllerDelegate {
	
	func willPresentSearchController(_ searchController: UISearchController) {
		add(searchDefinitionsViewController)
	}
	
	func willDismissSearchController(_ searchController: UISearchController) {
		searchDefinitionsViewController.remove()
	}
}
