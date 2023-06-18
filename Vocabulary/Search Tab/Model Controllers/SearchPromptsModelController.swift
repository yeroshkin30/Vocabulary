//
//  SearchPromptsModelController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 08.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

private let maxClipboardWords = 20

class SearchPromptsModelController: NSObject {

	// MARK: - Properties

	var promptsDataDidChangeHandler: (() -> Void)?

	private let historyManager: HistoryModelController
	private var clipboardWords: [String] = []
	private var currentSections: [Section] = []

	// MARK: - Initialization -

	init(historyManager: HistoryModelController) {
		self.historyManager = historyManager

		super.init()
		updateSectionsData()
		setupNotifications()
		historyManager.historyDataDidChangeHandler = { [weak self] in
			self?.updateSectionsData()
		}
	}

	// MARK: - Public methods

	func reloadData() {
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

// MARK: - Private methods -
private extension SearchPromptsModelController {

	func setupNotifications() {
		let enterForeground = UIApplication.willEnterForegroundNotification
		let pasteboardChanged = UIPasteboard.changedNotification

		NotificationCenter.default.addObserver(
			self, selector: #selector(updateSectionsData), name: enterForeground, object: nil
		)
		NotificationCenter.default.addObserver(
			self, selector: #selector(updateSectionsData), name: pasteboardChanged, object: nil
		)
	}

	func updateClipboardWords() {
		let pasteboardString = UIPasteboard.general.string
		let words = pasteboardString?.englishWords(limit: maxClipboardWords) ?? []
		clipboardWords = words
	}

	@objc
	func updateSectionsData() {
		updateClipboardWords()

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
private extension SearchPromptsModelController {

	enum Section: Int, CaseIterable {
		case clipboard, history

		var title: String {
			switch self {
			case .clipboard:	return "Clipboard"
			case .history:		return "History"
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension SearchPromptsModelController: UITableViewDataSource {

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
		let cell: UITableViewCell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		cell.textLabel?.text = text(for: indexPath)
		cell.detailTextLabel?.text = nil
		cell.accessoryType = .none
		return cell
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return currentSections[section].title
	}
}
