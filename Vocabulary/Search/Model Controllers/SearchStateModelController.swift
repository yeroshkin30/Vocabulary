//
//  SearchStateModelController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 08.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class SearchStateModelController: NSObject {

	private(set) var state: State = .prompts {
		didSet {
			stateDidChange()
		}
	}

	var stateDidChangeHandler: ((State, UITableViewDataSource?) -> Void)? {
		didSet {
			stateDidChangeHandler?(state, searchPromptsModelController)
		}
	}

	private let entriesLoader: EntriesLoader
	private let historyManager: HistoryModelController
	private let searchPromptsModelController: SearchPromptsModelController
	private var searchResultsDataSource: SearchResultsModelController?

	init(
		entriesLoader: EntriesLoader = EntriesLoader(),
		historyManager: HistoryModelController = HistoryModelController()
	) {
		self.entriesLoader = entriesLoader
		self.historyManager = historyManager
		self.searchPromptsModelController = SearchPromptsModelController(historyManager: historyManager)
	}

	func requestEntries(for word: String) {
		state = .loading(definitionsFor: word)
		entriesLoader.requestEntriesFor(word, with: { [weak self] (requestResult) in
			guard case .loading(_) = self?.state else { return }

			DispatchQueue.main.async {
				self?.handleResult(requestResult, for: word)
			}
		})
	}
}

private extension SearchStateModelController {

	func stateDidChange() {
		let currentDataSource: UITableViewDataSource?

		switch state {
		case .prompts: 			currentDataSource = searchPromptsModelController
		case .searchResult(_): 	currentDataSource = searchResultsDataSource
		default: 				currentDataSource = nil
		}

		stateDidChangeHandler?(state, currentDataSource)
	}

	func handleResult(_ result: EntriesParsingResult?, for word: String) {
		if let result = result {
			historyManager.saveWord(word)
			searchResultsDataSource = SearchResultsModelController(searchResult: result)
			state = .searchResult(result)
		} else {
			state = .noSearchResult(forRequest: word)
		}
	}
}

// MARK: - Types
extension SearchStateModelController {

	enum State: Equatable {
		case prompts
		case loading(definitionsFor: String)
		case noSearchResult(forRequest: String)
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

extension SearchStateModelController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch state {
		case .prompts:
			let promptText = searchPromptsModelController.promptAt(indexPath)
			requestEntries(for: promptText)
		case .searchResult(_):
			if let suggestions = state.resultSuggestions {
				requestEntries(for: suggestions[indexPath.row])

			} else {
				tableView.deselectRow(at: indexPath, animated: true)
			}
		default:
			break
		}
	}
}

extension SearchStateModelController: UISearchBarDelegate {

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText == "" , state != .prompts {
			state = .prompts
		}
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let word = searchBar.text, word != ""	else { return }
		requestEntries(for: word)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		state = .prompts
	}
}
