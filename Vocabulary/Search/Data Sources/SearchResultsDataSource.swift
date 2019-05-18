//
//	SearchResultsDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 1/17/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class SearchResultsDataSource: NSObject {
	
	private let searchResult: EntriesParsingResult
	
	// MARK: - Initialization -
	
	init(searchResult: EntriesParsingResult) {
		self.searchResult = searchResult
		
		super.init()
	}
}

// MARK: - Helpers -
private extension SearchResultsDataSource {
	
	func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
		
		switch searchResult {
		case .entries(let entries):
			let entry = entries[indexPath.row]
			
			cell.textLabel?.text = entry.headword
			cell.detailTextLabel?.text = entry.sentencePart
			cell.accessoryType = .disclosureIndicator
			
		case .suggestions(let suggestions):
			cell.textLabel?.text = suggestions[indexPath.row]
			cell.detailTextLabel?.text = nil
			cell.accessoryType = .none
		}
	}
}

// MARK: - UITableViewDataSource -
extension SearchResultsDataSource: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch searchResult {
		case .entries(let entries):			return entries.count
		case .suggestions(let suggestions):	return suggestions.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		configureCell(cell, at: indexPath)
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch searchResult {
		case .entries(_):		return "Entries"
		case .suggestions(_):	return "Suggestions"
		}
	}
}
