//
//	SearchTabViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 1/17/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol DefinitionsRequestProvider {
	var wordToRequest: String? { get }
}

class SearchTabViewController: UITableViewController, SegueHandlerType {

	// MARK: - Properties

	var vocabularyStore: VocabularyStore!
	var searchStateModelController: SearchStateModelController!
	var currentWordCollectionInfoProvider: CurrentWordCollectionInfoProvider!

	private lazy var searchController: UISearchController = .init(searchResultsController: nil)

	private lazy var loadingView: LoadingView = .instantiate()
	private lazy var messageView: MessageView = .instantiate()
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = searchStateModelController
		searchStateModelController.stateDidChangeHandler =  { [unowned self] (state, dataSource) in
			self.stateDidChange(state, currentDataSource: dataSource)
		}
		setupSearchController()
		setupNotifications()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		tabBarController?.delegate = self
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		searchController.searchBar.resignFirstResponder()
		tabBarController?.delegate = nil
	}
	
	override var textInputContextIdentifier: String? {
		return SearchTabViewController.stringIdentifier
	}
	
	// MARK: - Navigation -

	enum SegueIdentifier: String {
		case showEntry
	}
	
	@IBAction func unwindWithWordToRequest(_ segue: UIStoryboardSegue) {
		if let provider = segue.source as? DefinitionsRequestProvider,
			let word = provider.wordToRequest {
			
			searchStateModelController.requestEntries(for: word)
		}
	}

	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		searchStateModelController.state.resultEntries != nil
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let entries = searchStateModelController.state.resultEntries else { return }

		switch segueIdentifier(for: segue) {
		case .showEntry:
			let viewController = segue.destination as! EntryCollectionViewController
			viewController.vocabularyStore = vocabularyStore

			let index = tableView.indexPathForSelectedRow?.row ?? 0
			viewController.entry = entries[index]
			viewController.currentWordCollectionID = currentWordCollectionInfoProvider.wordCollectionInfo?.objectID
		}
	}
}

// MARK: - Helpers
private extension SearchTabViewController {

	func setupNotifications() {
		let name = UIApplication.willEnterForegroundNotification
		NotificationCenter.default
			.addObserver(self, selector: #selector(tableView.reloadData),  name: name, object: nil)
	}

	func setupSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.showsSearchResultsController = true
		searchController.searchBar.placeholder = "Search Definitions"
		searchController.searchBar.delegate = searchStateModelController
		searchController.searchBar.autocorrectionType = .yes

		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.searchController = searchController
	}
	
	func stateDidChange(_ state: SearchStateModelController.State, currentDataSource: UITableViewDataSource?) {
		
		tableView.dataSource = currentDataSource
		tableView.backgroundView = nil
		
		switch state {
		case .prompts: break

		case .loading(let text):
			searchController.searchBar.text = text
			searchController.searchBar.resignFirstResponder()
			tableView.backgroundView = loadingView
			
		case .noSearchResult(let request):
			messageView.message = MessageView.Message(
				title: "No Results", text: "for \"\(request)\""
			)
			tableView.backgroundView = messageView
			
		case .searchResult(_):
			checkSingleEntryResultCondition()
		}
		
		tableView.reloadData()
	}
	
	func checkSingleEntryResultCondition() {
		if let entries = searchStateModelController.state.resultEntries, entries.count == 1 {
			
			tableView.selectRow(at: IndexPath.first, animated: false, scrollPosition: .none)
			performSegue(with: .showEntry, sender: nil)
		}
	}
}

extension SearchTabViewController: UITabBarControllerDelegate {

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		if viewController == navigationController {
			searchController.searchBar.becomeFirstResponder()
		}
	}
}
