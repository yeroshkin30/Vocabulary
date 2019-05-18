//
//	EditWordViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/13/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol CollectWordDataViewControllerDelegate: AnyObject {
	func collectWordDataViewController(_ viewController: CollectWordDataViewController,
										didFinishWith action: CollectWordDataViewController.ResultAction)
}

class CollectWordDataViewController: UITableViewController, SegueHandlerType {
	
	enum ResultAction {
		case cancel, save, delete
	}
	
	var viewData = ViewData() { didSet { updateSaveButton() } }
	
	weak var delegate: CollectWordDataViewControllerDelegate?
	
	@IBOutlet private var saveButton: UIBarButtonItem!
	@IBOutlet private var addNewExampleButton: UIButton!
	
	// MARK: - Actions
	
	@IBAction private func saveButtonAction(_ sender: UIBarButtonItem) {
		delegate?.collectWordDataViewController(self, didFinishWith: .save)
	}
	
	@IBAction private func cancelButtonAction(_ sender: UIBarButtonItem) {
		delegate?.collectWordDataViewController(self, didFinishWith: .cancel)
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = viewData.mode == .create ? "Create word" : "Edit word"
		
		setEditing(true, animated: false)
		updateSaveButton()
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case editText, addExample
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if let indexPath = tableView.indexPathForSelectedRow,
			Section(at: indexPath) == .deletition {
			
			delegate?.collectWordDataViewController(self, didFinishWith: .delete)
			return false
		}
		return true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segueIdentifier(for: segue) {
		case .editText, .addExample:
			let viewController = segue.destination as! EditTextViewController
			
			viewController.delegate = self
			
			if let indexPath = tableView.indexPathForSelectedRow {
				viewController.initialText = textForCell(at: indexPath) ?? ""
				viewController.charactersCapacity = Section(at: indexPath).charactersCapacity
			} else {
				viewController.charactersCapacity = .large
			}
		}
	}
}

// MARK: - Private
private extension CollectWordDataViewController {
	
	var examplesHeaderView: UITableViewHeaderFooterView {
		let headerView = UITableViewHeaderFooterView(frame: .zero)
		headerView.addTrailingButton(addNewExampleButton)
		return headerView
	}
	
	func updateSaveButton() {
		let isHeadwordEmpty	= viewData.headword.isEmpty
		let isSentencePartEmpty = viewData.sentencePart.isEmpty
		let isDefinitionEmpty	= viewData.definition.isEmpty
		
		let hasEmptyField = isHeadwordEmpty || isSentencePartEmpty || isDefinitionEmpty
		
		saveButton.isEnabled = hasEmptyField == false
	}
	
	func textForCell(at indexPath: IndexPath) -> String? {
		switch Section(at: indexPath) {
		case .headword:	return viewData.headword
		case .sentencePart: return viewData.sentencePart
		case .definition:	return viewData.definition
		case .examples:	return viewData.examples[indexPath.row]
		case .deletition:	return "Delete Word"
		}
	}
	
	func updateText(at indexPath: IndexPath, with text: String) {
		switch Section(at: indexPath) {
		case .headword:	viewData.headword = text
		case .sentencePart: viewData.sentencePart = text
		case .definition:	viewData.definition = text
		case .examples:	viewData.examples[indexPath.row] = text
		default: break
		}
		updateSaveButton()
		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
	
	func addNewExample(with text: String) {
		
		let newExample = text.hasPrefix("- ") ? text : "- " + text
		
		viewData.examples.insert(newExample, at: 0)
		
		let newExampleIndexPath = IndexPath(row: 0, section: Section.examples.rawValue)
		
		tableView.insertRows(at: [newExampleIndexPath], with: .automatic)
	}
}

// MARK: - UITableViewDataSource
extension CollectWordDataViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewData.mode == .create ? Section.count - 1 : Section.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Section(section) == .examples ? viewData.examples.count : 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		
		cell.textLabel?.text = textForCell(at: indexPath)
		cell.textLabel?.textColor = Section(at: indexPath) == .deletition ? .red : .black
		cell.textLabel?.textAlignment = Section(at: indexPath) == .deletition ? .center : .left
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section(section).text
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return Section(at: indexPath) == .examples
	}
	
	override func tableView(_ tableView: UITableView,
							moveRowAt sourceIndexPath: IndexPath,
							to destinationIndexPath: IndexPath) {
		viewData.examples.swapAt(sourceIndexPath.row, destinationIndexPath.row)
	}
	
	override func tableView(_ tableView: UITableView,
							commit editingStyle: UITableViewCell.EditingStyle,
							forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			viewData.examples.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .none)
		}
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return Section(section) == .examples ? examplesHeaderView : nil
	}
}

// MARK: - UITableViewDelegate
extension CollectWordDataViewController {
	
	override func tableView(_ tableView: UITableView,
							editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		
		return Section(at: indexPath) == .examples ? .delete : .none
	}
	
	override func tableView(_ tableView: UITableView,
							shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return Section(at: indexPath) == .examples
	}
	
	override func tableView(_ tableView: UITableView,
							targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
							toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		
		switch Section(at: proposedDestinationIndexPath) {
		case .deletition:
			return IndexPath(row: viewData.examples.count - 1, section: Section.examples.rawValue)
		case .examples:
			return proposedDestinationIndexPath
		default:
			return IndexPath(row: 0, section: Section.examples.rawValue)
		}
	}
}

// MARK: - EditTextViewControllerDelegate -
extension CollectWordDataViewController: EditTextViewControllerDelegate {
	func editTextViewController(_ controller: EditTextViewController, saveEditedText text: String) {
		
		if let indexPath = tableView.indexPathForSelectedRow {
			updateText(at: indexPath, with: text)
		} else {
			addNewExample(with: text)
		}
		navigationController?.popViewController(animated: true)
	}
}

// MARK: - Types -
extension CollectWordDataViewController {
	
	enum ViewMode {
		case create, edit
	}
	
	struct ViewData {
		var headword: String = ""
		var sentencePart: String = ""
		var definition: String = ""
		var examples: [String] = []
		var mode: ViewMode = .create
	}
	
	enum Section: Int {
		case headword, sentencePart, definition, examples, deletition
		
		static let count = 5
		
		init(at indexPath: IndexPath) {
			self = Section.init(rawValue: indexPath.section)!
		}
		
		init(_ section: Int) {
			self = Section.init(rawValue: section)!
		}
		
		var text: String {
			switch self {
			case .headword:		return "Headword"
			case .sentencePart:	return "Sentence part"
			case .definition:	return "Definiton"
			case .examples:		return "Examples"
			case .deletition:	return ""
			}
		}
		
		var charactersCapacity: EditTextViewController.CharactersCapacity {
			switch self {
			case .headword, .sentencePart:	return .small
			default:						return .large
			}
		}
	}
}

extension CollectWordDataViewControllerDelegate {
	
	func fill(_ word: Word, with viewData: CollectWordDataViewController.ViewData) {
		word.headword		= viewData.headword
		word.sentencePart	= viewData.sentencePart
		word.definition		= viewData.definition
		word.examples		= viewData.examples
	}
}

extension CollectWordDataViewController.ViewData {
	
	init(word: Word) {
		headword		= word.headword
		sentencePart	= word.sentencePart
		definition		= word.definition
		examples		= word.examples
		mode			= word.isInserted ? .create : .edit
	}
}
