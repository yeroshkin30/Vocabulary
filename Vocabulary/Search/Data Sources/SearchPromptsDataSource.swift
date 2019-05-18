//
//	SearchPromptsDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 1/17/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

private let maxClipboardWords = 20

class SearchPromptsDataSource: NSObject {
	
	private let historyManager: HistoryManager
	
	private var clipboardWords: [String] = []
	
	private var currentSections: [Section] = []
	
	// MARK: - Initialization -
	
	init(historyManager: HistoryManager) {
		self.historyManager = historyManager
		
		super.init()
		
		updatePrompts()
	}
	
	func updatePrompts() {
		updateClipboardWords()
		updateSectionsData()
	}
	
	func promptAt(_ indexPath: IndexPath) -> String {
		let prompt: String
		
		switch currentSections[indexPath.section] {
		case .clipboard:	prompt = clipboardWords[indexPath.row]
		case .history:		prompt = historyManager[indexPath.row] ?? ""
		}
		
		return prompt
	}
}

// MARK: - Helpers -
private extension SearchPromptsDataSource {
	
	@objc func updateClipboardWords() {
		let pastboardString = UIPasteboard.general.string
		let words = pastboardString?.englishWords(limit: maxClipboardWords) ?? []
		clipboardWords = words
	}
	
	func updateSectionsData() {
		var sections: [Section] = []
		
		if !clipboardWords.isEmpty			{ sections.append(.clipboard) }
		if !historyManager.allWords.isEmpty	{ sections.append(.history) }
		
		currentSections = sections
	}
	
	func text(for indexPath: IndexPath) -> String? {
		switch currentSections[indexPath.section] {
		case .clipboard:	return clipboardWords[indexPath.row].capitalized
		case .history:		return historyManager[indexPath.row]?.capitalized
		}
	}
}

// MARK: - Types -
private extension SearchPromptsDataSource {
	enum Section: Int, CaseIterable {
		case clipboard
		case history
		
		var title: String {
			switch self {
			case .clipboard:	return "Clipboard"
			case .history:		return "History"
			}
		}
	}
}

extension SearchPromptsDataSource: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return currentSections.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch currentSections[section] {
		case .clipboard:	return clipboardWords.count
		case .history:		return historyManager.numberOfWords
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		cell.textLabel?.text = text(for: indexPath)
		cell.detailTextLabel?.text = nil
		cell.accessoryType = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return currentSections[section].title
	}
}
