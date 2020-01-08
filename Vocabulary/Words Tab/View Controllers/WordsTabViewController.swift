//
//  WordsTabViewController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 13.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class WordsTabViewController: UITableViewController, SegueHandlerType {

	// MARK: - Properties

	var vocabularyStore: VocabularyStore!
	var currentWordCollectionInfoProvider: CurrentWordCollectionInfoProvider!

	private var viewData: ViewData = .init(sections: []) {
		didSet {
			tableView.reloadData()
		}
	}

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()

		currentWordCollectionInfoProvider.addObserver(self)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		updateViewData()
	}

	// MARK: - Navigation

	enum SegueIdentifier: String {
		case showListOfWords
	}

	@IBSegueAction
	func makeListOfWordsViewController(
		coder: NSCoder,
		sender: Any?,
		segueIdentifier: String?
	) -> ListOfWordsViewController? {

		guard let indexPath = tableView.indexPathForSelectedRow else {
			return nil
		}

		let learningStage = Section(at: indexPath) == .allWords ? nil : Word.LearningStage(rawValue: Int16(indexPath.row))
		let currentWordCollectionID = currentWordCollectionInfoProvider.wordCollectionInfo?.objectID

		let modelController = ListOfWordsModelController(
			vocabularyStore: vocabularyStore,
			learningStage: learningStage,
			currentWordCollectionID: currentWordCollectionID
		)
		return ListOfWordsViewController(coder: coder,vocabularyStore: vocabularyStore, modelController: modelController)
	}

	// MARK: - UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewData.sections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewData.sections[section].count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell

		configureCell(cell, at: indexPath)

		return cell
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section(section).title
	}

	// MARK: - UITableViewDelegate

	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		let cellData = viewData.sections[indexPath.section][indexPath.row]

		return cellData.numberOfWords != 0
	}
}

// MARK: - Private
private extension WordsTabViewController {

	func updateViewData() {
		var sections: [ViewData.SectionData] = []

		Section.allCases.enumerated().forEach { (sectionIndex, section) in

			var cells: [ViewData.CellData] = []

			for row in 0..<section.numberOfRows {
				let indexPath = IndexPath(row: row, section: sectionIndex)
				let text = section.textAt(row)
				let numberOfWords = numberOfWordsForCell(at: indexPath)

				cells.append((text, numberOfWords))
			}

			sections.append(cells)
		}

		viewData = .init(sections: sections)
	}

	func numberOfWordsForCell(at indexPath: IndexPath) -> Int {
		let stage: Word.LearningStage?

		switch Section(at: indexPath) {
		case .allWords: 		stage = nil
		case .learningStages: 	stage = Word.LearningStage(rawValue: Int16(indexPath.row))
		}

		let parameters: WordsRequestParameters = (
			stage, currentWordCollectionInfoProvider.wordCollectionInfo?.objectID, false
		)
		let request = WordFetchRequestFactory.requestForWords(with: parameters)

		return vocabularyStore.numberOfWordsFrom(request)
	}

	func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
		let cellData = viewData.sections[indexPath.section][indexPath.row]
		let haveNoWords = cellData.numberOfWords == 0
		let textColor: UIColor = haveNoWords ? .lightGray 	: .black

		cell.textLabel?.text 			= cellData.text
		cell.detailTextLabel?.text 		= "\(cellData.numberOfWords)"
		cell.textLabel?.textColor 		= textColor
		cell.detailTextLabel?.textColor = textColor
		cell.accessoryType 				= haveNoWords ? .none : .disclosureIndicator
	}
}

// MARK: - Types
private extension WordsTabViewController {

	enum Section: Int, CaseIterable {
		case allWords, learningStages

		init(at indexPath: IndexPath) {
			self = Section.init(rawValue: indexPath.section)!
		}

		init(_ section: Int) {
			self = Section.init(rawValue: section)!
		}

		static let count = 2

		var title: String? {
			switch self {
			case .allWords:			return nil
			case .learningStages:	return "Learning Stages"
			}
		}

		var numberOfRows: Int {
			switch self {
			case .allWords:			return 1
			case .learningStages:	return Word.LearningStage.count
			}
		}

		func textAt(_ row: Int) -> String {
			switch self {
			case .allWords:			return "All words"
			case .learningStages:	return Word.LearningStage.names[row]
			}
		}
	}

	struct ViewData {
		typealias SectionData = [CellData]
		typealias CellData = (text: String, numberOfWords: Int)

		let sections: [SectionData]
	}
}

extension WordsTabViewController: CurrentWordCollectionInfoObserver {

	func currentWordCollectionDidChange(_ wordCollectionInfo: WordCollectionInfo?) {
		navigationItem.title = "\(wordCollectionInfo?.name ?? "Vocabulary")"
		updateViewData()
	}
}
