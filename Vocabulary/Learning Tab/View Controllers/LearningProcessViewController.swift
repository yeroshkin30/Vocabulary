//
//	LearningProcessViewController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/23/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

final class LearningProcessViewController: BaseWordsLearningViewController, SegueHandlerType {
	
	// MARK: - Types
	
	enum Mode {
		case remembering([Word])
		case repetition([Word])
	}
	
	// MARK: - Public properties
	
	var learningMode: Mode = .repetition([])
	
	// MARK: - Private properties
	
	private lazy var textFieldConfigurator = InputViewsConfigurator(context: vocabularyStore.viewContext)
	
	private lazy var answersHandler: AnswersReceiver = {
		let handler: AnswersReceiver = AnswersReceiver(textFieldConfigurator: textFieldConfigurator)
		handler.delegate = self
		return handler
	}()
	
	private var currentAnswerCorrectness: AnswerCorrectness?
	
	private lazy var endRepetitionMessageView: MessageView = {
		let view: MessageView = MessageView.instantiate()
		view.message = MessageView.Message(
			title: "Great work!", text: "You have repeated all available words.", actionTitle: "Back",
			actionClosure: { [weak self] in
				self?.navigationController?.popViewController(animated: true)
		})
		return view
	}()
	
	// MARK: - Actions
	
	@IBAction private func closeButtonAction(_ sender: UIBarButtonItem) {
		showCloseButtonActionSheet()
	}
	
	// MARK: - Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initialSetup()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		currentCell?.answerTextField.resignFirstResponder()
	}
	
	override var textInputContextIdentifier: String? {
		return String(describing: LearningProcessViewController.self)
	}
	
	// MARK: - BaseWordsLearningViewController -
	
	override func instantiateDataSource(with words: [Word]) -> WordsLearningCollectionViewDataSource {
		switch learningMode {
		case .remembering(let words):	return RememberWordsCollectionViewDataSource(words: words)
		case .repetition(let words):	return RepeatWordsCollectionViewDataSource(words: words)
		}
	}
	
	override func autoPronounceButtonTapped() {
		if autoPronounceButton.isSelected {
			stopPronouncing()
		} else if answersHandler.state == .finish, let word: Word = dataSource.currentWord {
			pronounce(word.headword)
		}
		autoPronounceButton.isSelected.toggle()
	}
	
	// MARK: - Navigation
	
	enum SegueIdentifier: String {
		case completeRemembering
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		guard segueIdentifier(for: segue) == .completeRemembering,
			case .remembering(let words) = learningMode	else {
				return
		}
		
		let viewController: RememberingCompletionViewController = segue.destination as! RememberingCompletionViewController
		viewController.learnedWords = words
	}
}

// MARK: - Private -
private extension LearningProcessViewController {
	
	func initialSetup() {
		switch learningMode {
		case .remembering(_):
			navigationItem.title = "Remember words"
		case .repetition(_):
			navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
		}
		
		NotificationCenter.default.addObserver(
			self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil
		)
		
		additionalSafeAreaInsets.bottom = UIScreen.main.bounds.height / 2
	}
	
	@objc func keyboardDidShow(_ notification: Notification) {
		guard let endFrame: CGRect = notification.userInfo![ UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		
		let requiredInset: CGFloat = view.frame.height - endFrame.origin.y
		
		if requiredInset != 0,
			additionalSafeAreaInsets.bottom != requiredInset {
			
			additionalSafeAreaInsets.bottom = requiredInset
			collectionView.setNeedsLayout()
			collectionView.layoutIfNeeded()
		}
	}
	
	var currentCell: LearningCollectionViewCell? {
		return collectionView.visibleCells.first as? LearningCollectionViewCell
	}
	
	func prepareForQuestion(_ cell: LearningCollectionViewCell) {
		guard let textField: UITextField = cell.answerTextField, let word: Word = dataSource.currentWord else {
			return
		}
		answersHandler.handle(textField, with: word)
		textField.becomeFirstResponder()
	}
	
	func completeLearning() {
		
		switch learningMode {
		case .remembering(let words):
			words.forEach { $0.increaseLearningStage() }
			vocabularyStore.saveChanges()
			performSegue(with: .completeRemembering, sender: nil)
			
		case .repetition(_):
			collectionView.backgroundView = endRepetitionMessageView
			additionalSafeAreaInsets.bottom = 0
		}
	}
	
	func showCloseButtonActionSheet() {
		let message: String = "Are you sure you want to stop remembering?"
		let alert: UIAlertController = .init(title: nil, message: message, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Stop", style: .destructive) { (_) in
			self.dismiss(animated: true)
		})
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			self.currentCell?.answerTextField.becomeFirstResponder()
		})
		present(alert, animated: true)
	}
}

// MARK: - UICollectionViewDelegate
extension LearningProcessViewController {
	
	func collectionView(_ collectionView: UICollectionView,
						didEndDisplaying cell: UICollectionViewCell,
						forItemAt indexPath: IndexPath) {
		
		if dataSource.questionsNumber == 0,
			let cell: LearningCollectionViewCell = cell as? LearningCollectionViewCell {
			
			cell.answerTextField.resignFirstResponder()
			completeLearning()
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								willDisplay cell: UICollectionViewCell,
								forItemAt indexPath: IndexPath) {
		
		if let cell: LearningCollectionViewCell = cell as? LearningCollectionViewCell {
			prepareForQuestion(cell)
		}
	}
}

// MARK: - LearningWordsAnswersHandlerDelegate -
extension LearningProcessViewController: LearningWordsAnswersHandlerDelegate {
	
	func answersReceiver(_ handler: AnswersReceiver,
						didAcceptAnswer answer: AnswerCorrectness) {
		
		currentAnswerCorrectness = answer
		currentCell?.selectToAnswer(answer)
		
		if autoPronounceButton.isSelected {
			pronounce(dataSource.currentWord?.headword ?? "")
		}
		
		if case .repetition(_) = learningMode {
			switch answer {
			case .correct:		dataSource.currentWord?.increaseLearningStage()
			case .incorrect:	dataSource.currentWord?.decreaseLearningStage()
			}
			vocabularyStore.saveChanges()
		}
	}
	
	func answersReceiverReadyForNextQuestion(_ handler: AnswersReceiver) {
		guard let answer: AnswerCorrectness = currentAnswerCorrectness else { return }
		
		switch answer {
		case .correct:
			dataSource.collectionView(collectionView, reactToAnswerImpact: .positive)
			
		case .incorrect:
			dataSource.collectionView(collectionView, reactToAnswerImpact: .negative)
		}
		updateProgressView()
	}
}
