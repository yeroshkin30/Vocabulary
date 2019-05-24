//
//	ChooseLearningStageViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 5/5/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class ChooseLearningStageViewController: UITableViewController {
	
	private let cellID = String(describing: UITableViewCell.self)
	
	private lazy var optionNames: [String] = {
		return ["All Words"] + Word.LearningStage.names
	}()
	
	var vocabularyStore: VocabularyStore!
	
	var learningStageChangeHandler: ((Word.LearningStage?) -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.tableFooterView = UIView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let height = tableView.contentSize.height
		let width = UIScreen.main.bounds.width / 2
		preferredContentSize = CGSize(width: width, height: height)
		tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return optionNames.count
	}
	
	override func tableView(_ tableView: UITableView,
							cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: cellID) {
			configure(cell, at: indexPath)
			return cell
			
		} else {
			let cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
			configure(cell, at: indexPath)
			return cell
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let stage = learningStage(at: indexPath)
		
		guard numberOfWords(at: stage) > 0 else {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		learningStageChangeHandler?(stage)
		dismiss(animated: true)
	}
}

// MARK: - Private -
private extension ChooseLearningStageViewController {
	
	func learningStage(at indexPath: IndexPath) -> Word.LearningStage? {
		return Word.LearningStage(rawValue: Int16(indexPath.row - 1))
	}
	
	func numberOfWords(at learningStage: Word.LearningStage?) -> Int {
		let parameters: WordsRequestParameters = (
			learningStage, currentWordCollectionInfo?.objectID, false
		)
		let request = FetchRequestFactory.requestForWords(with: parameters)
		return vocabularyStore.numberOfWordsFrom(request)
	}
	
	func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
		let option = optionNames[indexPath.row]
		let stage = learningStage(at: indexPath)
		let number = numberOfWords(at: stage)
		
		cell.textLabel?.text = option
		cell.detailTextLabel?.text = "\(number)"
	}
}
