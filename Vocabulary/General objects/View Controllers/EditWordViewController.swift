//
//	EditWordViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/13/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class EditWordViewController: UITableViewController, SegueHandlerType {

	enum ViewMode: String {
		case create = "Create word"
		case edit = "Edit word"
	}
	
	enum ResultAction {
		case cancel, save, delete
	}

	// MARK: - Initialization

	private let word: Word
	private let viewMode: ViewMode
	private let wordEditingDidFinishHandler: ((ResultAction) -> Void)

	init?(
		coder: NSCoder,
		word: Word,
		viewMode: ViewMode,
		wordEditingDidFinishHandler: @escaping ((ResultAction) -> Void)
	) {
		self.word = word
		self.viewMode = viewMode
		self.wordEditingDidFinishHandler = wordEditingDidFinishHandler

		super.init(coder: coder)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Outlets
	
	@IBOutlet private var saveButton: UIBarButtonItem!
	@IBOutlet private var addNewExampleButton: UIButton!
	
	// MARK: - Actions
	
	@IBAction private func saveButtonAction(_ sender: UIBarButtonItem?) {
		dismiss(animated: true) {
			self.wordEditingDidFinishHandler(.save)
		}
	}
	
	@IBAction private func cancelButtonAction(_ sender: UIBarButtonItem?) {
		dismiss(animated: true) {
			self.wordEditingDidFinishHandler(.cancel)
		}
	}
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		title = viewMode.rawValue
		setEditing(true, animated: false)
		navigationController?.presentationController?.delegate = self
		updateSaveButton()
	}

	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case editText, addExample
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if	let cell: UITableViewCell = sender as? UITableViewCell,
			let indexPath: IndexPath = tableView.indexPath(for: cell),
			Section(at: indexPath) == .deletion {

			return false
		}
		return true
	}

	@IBSegueAction
	private func makeInputTextViewController(
		coder: NSCoder,
		sender: Any?,
		segueIdentifier: String?
	) -> InputTextViewController? {
		if let indexPath: IndexPath = tableView.indexPathForSelectedRow {

			let section: Section = Section(at: indexPath)
			let title: String = section.titleForInputTextViewController()
			let text: String? = textForCell(at: indexPath)
			let capacity: CharactersNumberPreset = section.charactersCapacity

			return InputTextViewController(coder: coder, title: title, initialText: text, charactersCapacity: capacity) {
				self.saveInputedText($0, at: indexPath)
			}
		} else {
			let title: String = "Enter new example"
			return InputTextViewController(coder: coder, title: title, charactersCapacity: .large) { (text) in
				self.saveInputedText(text, at: nil)
			}
		}
	}

	private func showDismissAlert() {
		let presenter: DismissActionSheetPresenter = .init(discardHandler: { (_) in
			self.cancelButtonAction(nil)
		}, saveHandler: { (_) in
			self.saveButtonAction(nil)
		})

		presenter.present(in: self)
	}
}

// MARK: - Private
private extension EditWordViewController {

	func updateSaveButton() {

		let hasEmptyField: Bool = word.headword.isEmpty || word.sentencePart.isEmpty || word.definition.isEmpty

		saveButton.isEnabled = hasEmptyField == false
	}

	func saveInputedText(_ InputedText: String, at indexPath: IndexPath?) {

		let text: String = InputedText.trimmingCharacters(in: .whitespacesAndNewlines)

		if let indexPath: IndexPath = indexPath {
			updateText(at: indexPath, with: text)
			if Section(at: indexPath) == .examples {
				tableView.reloadRows(at: [indexPath], with: .automatic)
			} else {
				tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
			}
		} else {
			addNewExample(with: text)
		}
	}

	func updateText(at indexPath: IndexPath, with text: String) {
		switch Section(at: indexPath) {
		case .headword:		word.headword = text
		case .sentencePart: word.sentencePart = text
		case .definition:	word.definition = text
		case .examples:		word.examples[indexPath.row] = text
		default: break
		}
		updateSaveButton()
	}

	func addNewExample(with text: String) {
		word.examples.insert(text, at: 0)
		let newExampleIndexPath: IndexPath = IndexPath(row: 0, section: Section.examples.rawValue)
		tableView.insertRows(at: [newExampleIndexPath], with: .automatic)
	}
}

// MARK: - UITableViewDataSource
extension EditWordViewController {

	private var examplesHeaderView: UITableViewHeaderFooterView {
		let headerView: UITableViewHeaderFooterView = .init(frame: .zero)
		headerView.addTrailingButton(addNewExampleButton)
		return headerView
	}

	private func textForCell(at indexPath: IndexPath) -> String? {
		switch Section(at: indexPath) {
		case .headword:		return word.headword
		case .sentencePart: return word.sentencePart
		case .definition:	return word.definition
		case .examples:		return word.examples[indexPath.row]
		case .deletion:		return "Delete Word"
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewMode == .create ? Section.count - 1 : Section.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Section(section) == .examples ? word.examples.count : 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell: UITableViewCell = tableView.dequeueCell(indexPath: indexPath) as UITableViewCell
		
		cell.textLabel?.text = textForCell(at: indexPath)
		cell.textLabel?.textColor = Section(at: indexPath) == .deletion ? .systemRed : .label
		cell.textLabel?.textAlignment = Section(at: indexPath) == .deletion ? .center : .left
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section(section).headerText
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		let currentSection: Section = Section(section)
		switch currentSection {
		case .headword:
			if word.headword.isEmpty {
				return currentSection.footerText
			}
		case .sentencePart:
			if word.sentencePart.isEmpty {
				return currentSection.footerText
			}
		case .definition:
			if word.definition.isEmpty {
				return currentSection.footerText
			}
		case .examples, .deletion: 	break
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return Section(at: indexPath) == .examples
	}
	
	override func tableView(_ tableView: UITableView,
							moveRowAt sourceIndexPath: IndexPath,
							to destinationIndexPath: IndexPath) {

		word.examples.swapAt(sourceIndexPath.row, destinationIndexPath.row)
	}
	
	override func tableView(_ tableView: UITableView,
							commit editingStyle: UITableViewCell.EditingStyle,
							forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			word.examples.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .none)
		}
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return Section(section) == .examples ? examplesHeaderView : nil
	}
}

// MARK: - UITableViewDelegate
extension EditWordViewController {

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		if Section(at: indexPath) == .deletion {
			dismiss(animated: true) {
				self.wordEditingDidFinishHandler(.delete)
			}
		}
	}
	
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
		case .deletion:
			return IndexPath(row: word.examples.count - 1, section: Section.examples.rawValue)
		case .examples:
			return proposedDestinationIndexPath
		default:
			return IndexPath(row: 0, section: Section.examples.rawValue)
		}
	}

	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let footerView: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
			footerView.textLabel?.textColor = .systemRed
		}
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension EditWordViewController: UIAdaptivePresentationControllerDelegate {

	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		return !word.hasChanges || word.isInserted
	}

	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		wordEditingDidFinishHandler(.cancel)
	}

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		showDismissAlert()
	}
}

// MARK: - Types -
private extension EditWordViewController {
	
	enum Section: Int {
		case headword, sentencePart, definition, examples, deletion
		
		static let count: Int = 5
		
		init(at indexPath: IndexPath) {
			self = Section.init(rawValue: indexPath.section)!
		}
		
		init(_ section: Int) {
			self = Section.init(rawValue: section)!
		}
		
		var headerText: String {
			switch self {
			case .headword:		return "Headword"
			case .sentencePart:	return "Sentence part"
			case .definition:	return "Definition"
			case .examples:		return "Examples"
			case .deletion:		return ""
			}
		}

		var footerText: String? {
			switch self {
			case .headword:		return "Please enter headword"
			case .sentencePart:	return "Please enter sentence part"
			case .definition:	return "Please enter definition"
			default: 			return nil
			}
		}
		
		var charactersCapacity: CharactersNumberPreset {
			switch self {
			case .headword, .sentencePart:	return .small
			default:						return .large
			}
		}

		func titleForInputTextViewController() -> String {
			let text: String
			switch self {
			case .headword, .sentencePart, .definition:
				text = headerText.lowercased()
			case .examples:
				text =  "example"
			default:
				fatalError()
			}
			return "Enter " + text
		}
	}
}
