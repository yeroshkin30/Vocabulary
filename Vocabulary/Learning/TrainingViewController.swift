//
//  TrainingViewController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 3/24/18.
//  Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

private let fourInchScreenWidth: CGFloat = 320.0

protocol TrainingViewControllerDataSource: UICollectionViewDataSource {
	var stopViewUdate: Bool { get set }
	var currentWord: Word? { get }
	var numberOfQuestions: Int { get }
	var delegate: TrainingViewControllerDataSourceDelegate? { get set }
}

protocol HeadwordInputViewController {
	var headword: String? { get set }
	var inputView: UIView { get }
}

class TrainingViewController: UIViewController {
	
	// MARK: - Public properties
	
	var trainingMode: TrainingMode = .repetition()
	var coreDataService: CoreDataService!
	
	// MARK: - Outlet properties
	
	@IBOutlet private weak var collectionView: UICollectionView!
	@IBOutlet private weak var collectionViewLayout: UICollectionViewFlowLayout!
	
	@IBOutlet private weak var pronounceToggle: UIButton!
	@IBOutlet private weak var progressView: UIProgressView!
	
	@IBOutlet private var keyboardAccessoryView: UIToolbar!
	@IBOutlet private var forgotAccessoryButton: UIBarButtonItem!
	@IBOutlet private var nextAccessoryButton: UIBarButtonItem!
	@IBOutlet private var againAccessoryButton: UIBarButtonItem!
	@IBOutlet private var flexibleSpaceAccessoryButton: UIBarButtonItem!
	
	// MARK: - Private properties
	
	private var wordsDataSource: TrainingViewControllerDataSource!
	
	private var canChangeTextInTextField = true
	
	private var currentTextField: UITextField? {
		didSet {
			currentAnswer = nil
			canChangeTextInTextField = true
			setupKeyboardAccessoryView(.forgot)
			
			currentTextField?.delegate = self
			currentTextField?.inputView = inputViewForCurrentCell()
			currentTextField?.inputAccessoryView = keyboardAccessoryView
			
			currentTextField?.becomeFirstResponder()
		}
	}
	
	private var currentAnswer: Bool? {
		didSet {
			let mode = KeyboardAccesoryViewMode(answer: currentAnswer)
			setupKeyboardAccessoryView(mode)
		}
	}
	
	private var totalProggres = 1
	private var currentProgress = 0 {
		didSet {
			let progress = Float(currentProgress) / Float(totalProggres)
			progressView.setProgress(progress, animated: true)
		}
	}
	
	private var backgroundMessageView: BackgroundMessageView? {
		let nib = UINib(nibName: BackgroundMessageView.nibName, bundle: nil)
		let messageView = nib.instantiate(withOwner: nil,
										  options: nil).first as! BackgroundMessageView
		messageView.delegate = self
		
		messageView.title = "Great work!"
		messageView.message = "You repeated all available words."
		messageView.utilityButtonsTytle = "Back"
		return messageView
	}
	
	// MARK: - Input Views
	
	private var customInputType: CustomInputType {
		guard let word = wordsDataSource.currentWord else { return .none }
		
		switch word.trainingStage {
		case .rememberSelection,
			 .repeatSelection:		return .selectHeadword
		case .rememberConstruction,
			 .repeatConstruction:	return .constructHeadword
		default: 					return .none
		}
	}
	private lazy var selectHeadwordController: SelectHeadwordController = {
		let controller = SelectHeadwordController(context: coreDataService.context)
		controller.delegate = self
		
		return controller
	}()
	
	private lazy var constructHeadwordController: ConstructHeadwordController = {
		let inputView = ConstructHeadwordController()
		inputView.delegate = self
		return inputView
	}()
	
	// MARK: - Types
	
	enum TrainingMode {
		case remembering(rememberedWords: [Word])
		case repetition()
	}
	
	private enum CustomInputType {
		case selectHeadword
		case constructHeadword
		case none
	}
	
	private enum KeyboardAccesoryViewMode {
		case empty
		case forgot
		case next
		case again
		
		init(answer: Bool?) {
			self = answer == true ? .empty : (answer == false ? .next : .forgot)
		}
	}
	
	// MARK: - Actions
	
	@IBAction private func nextAccessoryButtonAction(_ sender: UIBarButtonItem) {
		updateCurrentWord()
	}
	
	@IBAction private func forgotAccessoryButtonAction(_ sender: UIBarButtonItem) {
		
		handleAnswer(answerText: currentCell?.answerTextField.text ?? "")
		
		switch customInputType {
		case .selectHeadword: 		selectHeadwordController.headword = nil
		case .constructHeadword: 	constructHeadwordController.headword = nil
		case .none: break
		}
	}
	
	@IBAction private func againAccessoryButtonAction(_ sender: UIBarButtonItem) {
		guard let headword = wordsDataSource.currentWord?.headword else { return }
		currentCell?.answerTextField.text = ""
		constructHeadwordController.headword = headword
		setupKeyboardAccessoryView(.forgot)
	}
	
	@IBAction private func pronounceToggleAction(_ sender: UIButton) {
		pronounceToggle.isSelected = !pronounceToggle.isSelected
		
		if pronounceToggle.isSelected, currentAnswer != nil,
			let word = wordsDataSource.currentWord {
			pronounce(word.headword)
		} else {
			stopPronouncing()
		}
	}
	
	@IBAction private func closeButtonAction(_ sender: UIBarButtonItem) {
		currentCell?.answerTextField.resignFirstResponder()
		
		showCloseButtonActionSheet()
	}
	
	// MARK: - Life cicle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		wordsDataSource = TrainingWordsDataSource(collectionView: collectionView,
												  trainingMode: trainingMode,
												  context: coreDataService.context,
												  fetchRequest: fetchRequest)
		wordsDataSource.delegate = self
		collectionView.dataSource = wordsDataSource
		
		if case .repetition = trainingMode {
			navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
		}
		
		totalProggres = wordsDataSource.numberOfQuestions
		currentProgress = 0
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		collectionView.backgroundView = nil
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		stopPronouncing()
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		guard case .completeRemembering = segueIdentifier(for: segue),
			case .remembering(let words) = trainingMode
			else { return }
		
		let viewController = segue.destination as! RememberingCompletionViewController
		viewController.learnedWords = words
	}
	
	// MARK: - Helpers
	
	private var fetchRequest: NSFetchRequest<Word> {
		let setOfWords = coreDataService.selectedSetOfWords
		
		switch trainingMode {
		case .remembering(_):
			
			let fetchRequest = coreDataService.wordsFetchRequesAt(learningStage: .remembering,
																  from: setOfWords,
																  considerNextTrainingDate: false)
			fetchRequest.sortDescriptors = [
				NSSortDescriptor(key: #keyPath(Word.trainingStageValue), ascending: true),
				NSSortDescriptor(key: #keyPath(Word.nextTrainingDate), ascending: true)
			]
			return fetchRequest
		case .repetition():
			
			let fetchRequest = coreDataService.wordsFetchRequesAt(learningStage: .repetition,
																  from: setOfWords,
																  considerNextTrainingDate: true)
			fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Word.nextTrainingDate),
															 ascending: true)]
			return fetchRequest
		}
	}
	
	private var currentCell: LearningCollectionViewCell? {
		guard let indexPath = collectionView.indexPathsForVisibleItems.first,
			let cell = collectionView.cellForItem(at: indexPath) as? LearningCollectionViewCell else {
				return nil
		}
		return cell
	}
	
	private func inputViewForCurrentCell() -> UIView? {
		guard let word = wordsDataSource.currentWord else { return nil }
		
		switch customInputType {
		case .selectHeadword:
			selectHeadwordController.headword = word.headword
			return selectHeadwordController.inputView
			
		case .constructHeadword:
			constructHeadwordController.headword = word.headword
			return constructHeadwordController.inputView
			
		case .none:
			return nil
		}
	}
	
	private func setupKeyboardAccessoryView(_ accessoryViewMode: KeyboardAccesoryViewMode) {
		
		let items: [UIBarButtonItem]
		
		switch accessoryViewMode {
		case .empty: 	items = []
		case .forgot:	items = [forgotAccessoryButton, flexibleSpaceAccessoryButton]
		case .next:		items = [flexibleSpaceAccessoryButton, nextAccessoryButton]
		case .again:	items = [forgotAccessoryButton, flexibleSpaceAccessoryButton,
								 againAccessoryButton]
		}
		keyboardAccessoryView.items = items
	}
	
	private func handleAnswer(answerText: String) {
		guard let word = wordsDataSource.currentWord else { return }
		
		currentAnswer = word.headword.lowercased() == answerText.lowercased()
		
		canChangeTextInTextField = false
		currentCell?.selectToAnswer(isCorrect: currentAnswer!)
		
		if pronounceToggle.isSelected {
			pronounce(word.headword)
		}
		
		if currentAnswer == true {
			let inOneSecond = DispatchTime.now() + .seconds(1)
			DispatchQueue.main.asyncAfter(deadline: inOneSecond) { [weak self] in
				self?.currentProgress += 1
				self?.updateCurrentWord()
			}
		}
		
		if currentAnswer == false, case .repetition = trainingMode {
			self.currentProgress += 1
		}
	}
	
	private func updateCurrentWord() {
		guard let answer = currentAnswer, let word = wordsDataSource.currentWord else { return }
		
		switch (trainingMode, answer) {
		case (_, true):
			
			if case .remembering(var words) = trainingMode,
				word.trainingStage == .rememberInput {
				
				words.append(word)
				trainingMode = .remembering(rememberedWords: words)
			}
			word.trainingStage.up()
			
		case (.remembering, false):
			word.updateNextTrainingDate()
			
		case (.repetition, false):
			if word.trainingStage == .repeatSelection {
				word.trainingStage = .untrained
			} else {
				word.trainingStage.down()
			}
		}
		
		if case .repetition = trainingMode {
			coreDataService.saveChanges()
		}
	}
	
	private func showCloseButtonActionSheet() {
		let message = """
You can keep chosen words and learn them later or you can discard them and choose the new ones.
"""
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
		
		let keepHandler: ((UIAlertAction) -> Void) = { (_) in
			self.wordsDataSource.stopViewUdate = true
			self.coreDataService.discardChanges()
			self.dismiss(animated: true, completion: nil)
		}
		
		let discardHandler: ((UIAlertAction) -> Void) = { (_) in
			self.wordsDataSource.stopViewUdate = true
			self.coreDataService.discardChanges()
			self.discardAllRememberingWords()
			self.coreDataService.saveChanges()
			self.dismiss(animated: true, completion: nil)
		}
		
		let cancelHandler: ((UIAlertAction) -> Void) = { (_) in
			self.currentCell?.answerTextField.becomeFirstResponder()
		}
		
		alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: keepHandler))
		alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: discardHandler))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
		
		present(alert, animated: true, completion: nil)
	}
	
	private func discardAllRememberingWords() {
		guard case .remembering = trainingMode else { return }
		
		if let wordsOnRemembering = try? coreDataService.context.fetch(fetchRequest) {
			wordsOnRemembering.forEach {
				$0.trainingStage = .untrained
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension TrainingViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
						forItemAt indexPath: IndexPath) {
		
		guard let cell = cell as? LearningCollectionViewCell,
			let textField = cell.answerTextField else { return }
		
		currentTextField = textField
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrainingViewController: UICollectionViewDelegateFlowLayout {
	
	var itemWidth: CGFloat {
		let screenWidth = UIScreen.main.bounds.width
		return screenWidth * 0.8
	}
	
	var itemHeight: CGFloat {
		return UIScreen.main.bounds.width == fourInchScreenWidth ? itemWidth - 30 : itemWidth
	}
	
	var gorizontalInset: CGFloat {
		return (UIScreen.main.bounds.width - itemWidth) / 2
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: itemWidth, height: itemHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		
		let topInset: CGFloat = UIScreen.main.bounds.width == fourInchScreenWidth ? 10 : 25.0
		let bottomInset = collectionView.bounds.height - itemHeight - topInset
		
		return UIEdgeInsetsMake(topInset, gorizontalInset, bottomInset, gorizontalInset)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		
		return gorizontalInset * 2
	}
}

// MARK: - TrainingViewControllerDataSourceDelegate
extension TrainingViewController: TrainingViewControllerDataSourceDelegate {
	
	func allQuestionWereAnswered() {
		setupKeyboardAccessoryView(.empty)
		currentTextField?.resignFirstResponder()
		switch trainingMode {
		case .remembering:
			coreDataService.saveChanges()
			performSegue(withIdentifier: .completeRemembering, sender: nil)
		case .repetition:
			collectionView.backgroundView = backgroundMessageView
		}
	}
}

// MARK: - UITextFieldDelegate
extension TrainingViewController: UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
				   replacementString string: String) -> Bool {
		return canChangeTextInTextField
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if canChangeTextInTextField {
			handleAnswer(answerText: textField.text ?? "")
		} else {
			updateCurrentWord()
		}
		return true
	}
}

// MARK: - SelectHeadwordInputViewDelegate
extension TrainingViewController: SelectHeadwordControllerDelegate {
	
	func didSelect(headword: String) {
		guard let cell = currentCell else { return }
		
		cell.answerTextField.text = headword
		handleAnswer(answerText: headword)
	}
}

// MARK: - ConstructHeadwordControllerDelegate
extension TrainingViewController: ConstructHeadwordControllerDelegate {
	
	func didSelect(letter: String) {
		guard let cell = currentCell else { return }
		
		if cell.answerTextField.text?.isEmpty ?? true {
			
			cell.answerTextField.text = letter.capitalized
		} else {
			cell.answerTextField.text?.append(letter)
		}
		
		setupKeyboardAccessoryView(.again)
	}
	
	func headwordConstructed() {
		guard let answer = currentCell?.answerTextField.text else { return }
		
		handleAnswer(answerText: answer)
	}
}

// MARK: - BackgroundMessageViewDelegate
extension TrainingViewController: BackgroundMessageViewDelegate {
	
	func utilityButtonDidTapped() {
		navigationController?.popViewController(animated: true)
	}
}

// MARK: - SegueHandlerType
extension TrainingViewController: SegueHandlerType {
	enum SegueIdentifier: String {
		case completeRemembering
	}
}

// MARK: - TrainingTextField
class TrainingTextField: UITextField {
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return false
	}
}
