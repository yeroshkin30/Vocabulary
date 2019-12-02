//
//	SearchDefinitionsTableViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 1/17/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol DefinitionsRequestProvider {
	var wordToRequest: String? { get }
}

class SearchDefinitionsTableViewController: UITableViewController {
	
	var vocabularyStore: VocabularyStore!
	
	var searchBar: UISearchBar! { didSet { searchBar?.delegate = self } }
	
	// MARK: - Private properties
	
	private var entriesLoader = EntriesLoader()
	private var historyManager = HistoryManager()
	
	private lazy var loadingView: LoadingView = LoadingView.instantiate()
	private lazy var messageView: MessageView = MessageView.instantiate()
	
	private lazy var promptsDataSource = SearchPromptsDataSource(historyManager: historyManager)
	private var resultsDataSource: SearchResultsDataSource?
	
	private var viewMode: ViewMode = .loading { didSet { viewModeDidChange() } }
	
	// MARK: - Life cicle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewMode = .prompts
		setupNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		searchBar.resignFirstResponder()
	}
	
	override var textInputContextIdentifier: String? {
		return SearchDefinitionsTableViewController.stringIdentifier
	}
	
	deinit {
		removeNotifications()
	}
	
	// MARK: - Navigation -
	
	@IBAction func unwindWithWordToRequest(_ segue: UIStoryboardSegue) {
		if let provider = segue.source as? DefinitionsRequestProvider,
			let word = provider.wordToRequest {
			
			requestEntries(for: word)
		}
	}
	
	// MARK: - UITableViewDelegate -
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch viewMode {
		case .prompts:
			let prompt = promptsDataSource.promptAt(indexPath)
			requestEntries(for: prompt)
		case .searchResult(_):
			if let suggestions = viewMode.resultSuggestions {
				requestEntries(for: suggestions[indexPath.row])

			} else if let entries = viewMode.resultEntries {
				showEntryController(with: entries[indexPath.row])
				tableView.deselectRow(at: indexPath, animated: true)
			}
		default:
			break
		}
	}

	private func showEntryController(with entry: Entry) {
		let entryViewController = UIStoryboard(storyboard: .home)
			.instantiateViewController() as EntryCollectionViewController

		entryViewController.vocabularyStore = vocabularyStore
		entryViewController.entry = entry

		presentingViewController?.navigationController?.pushViewController(entryViewController, animated: true)
	}
}

// MARK: - Helpers
private extension SearchDefinitionsTableViewController {
	
	func setupNotifications() {
		let enterForeground = UIApplication.willEnterForegroundNotification
		let pasteboardChanged = UIPasteboard.changedNotification
		
		NotificationCenter.default.addObserver(
			self, selector: #selector(updatePrompts), name: enterForeground, object: nil
		)
		NotificationCenter.default.addObserver(
			self, selector: #selector(updatePrompts), name: pasteboardChanged, object: nil
		)
	}
	
	func removeNotifications() {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func updatePrompts() {
		guard case .prompts = viewMode else { return }
		
		promptsDataSource.updatePrompts()
		tableView.reloadData()
	}
	
	func viewModeDidChange() {
		
		tableView.dataSource = nil
		tableView.backgroundView = nil
		
		switch viewMode {
		case .prompts:
			promptsDataSource.updatePrompts()
			tableView.dataSource = promptsDataSource
			
		case .loading:
			searchBar.resignFirstResponder()
			tableView.backgroundView = loadingView
			
		case .noSearchResultFor(let request):
			messageView.message = MessageView.Message(
				title: "No Results", text: "for \"\(request)\""
			)
			tableView.backgroundView = messageView
			
		case .searchResult(let result):
			resultsDataSource = SearchResultsDataSource(searchResult: result)
			tableView.dataSource = resultsDataSource
			checkSingleEntryResultComdition()
		}
		
		tableView.reloadData()
	}
	
	func requestEntries(for word: String) {
		searchBar.text = word.capitalized
		viewMode = .loading
		entriesLoader.requestEntriesFor(word, with: { [weak self] (requestResult) in
			guard self?.viewMode == .loading else { return }
			
			DispatchQueue.main.async {
				self?.handleResult(requestResult, for: word)
			}
		})
	}
	
	func handleResult(_ result: EntriesParsingResult?, for word: String) {
		if let result = result {
			historyManager.saveWord(word)
			viewMode = .searchResult(result)
		} else {
			viewMode = .noSearchResultFor(request: word)
		}
	}
	
	func checkSingleEntryResultComdition() {
		if let entries = viewMode.resultEntries, entries.count == 1 {
			
			let firstCellIndexPath = IndexPath.first
			tableView.selectRow(at: firstCellIndexPath, animated: false, scrollPosition: .none)
			showEntryController(with: entries[0])
		}
	}
}

// MARK: - Types
extension SearchDefinitionsTableViewController {
	
	enum ViewMode: Equatable {
		case prompts, loading
		case noSearchResultFor(request: String)
		case searchResult(EntriesParsingResult)
		
		var resultEntries: [Entry]? {
			if case .searchResult(let result) = self, case .entries(let entries) = result {
				return entries
			}
			return nil
		}
		
		var resultSuggestions: [String]? {
			if case .searchResult(let result) = self, case .suggestions(let suggestions) = result {
				return suggestions
			}
			return nil
		}
	}
}

// MARK: - UISearchBarDelegate
extension SearchDefinitionsTableViewController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText == "" , viewMode != .prompts {
			viewMode = .prompts
		}
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let word = searchBar.text, word != ""	else { return }
		requestEntries(for: word)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		viewMode = .prompts
	}
}
