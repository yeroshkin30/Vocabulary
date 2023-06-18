//
//	AnswersReceiver.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/25/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

enum AnswerCorrectness {
	case correct, incorrect
}

protocol LearningWordsAnswersHandlerDelegate: AnyObject {
	func answersReceiver(_ handler: AnswersReceiver,
						didAcceptAnswer answer: AnswerCorrectness)
	func answersReceiverReadyForNextQuestion(_ handler: AnswersReceiver)
}

class AnswersReceiver: NSObject {
	
	// MARK: - Types -
	
	enum State {
		case start, receiving, finish
	}
	
	// MARK: - Initialization -
	
	private var configurator: InputViewsConfigurator
	
	init(textFieldConfigurator: InputViewsConfigurator) {
		self.configurator = textFieldConfigurator
		super.init()
		
		configurator.textFieldDelegate = self
	}
	
	// MARK: - Public properties
	
	var state: State = .start {
		didSet { configurator.state = state}
	}
	
	weak var delegate: LearningWordsAnswersHandlerDelegate?
	
	// MARK: - Private properties
	
	private var currentTextField: UITextField?
	private var currentHeadword: String?
	
	// MARK: - Public methods
	
	func handle(_ textField: UITextField, with word: Word) {
		state = .start
		
		currentTextField = textField
		currentHeadword = word.headword
		
		configurator.setup(textField, for: word)
	}
}

// MARK: - Private -
private extension AnswersReceiver {
	
	func handleAcceptedAnswer() {
		state = .finish
		
		let answer: AnswerCorrectness
		
		if currentTextField?.text?.lowercased() == currentHeadword?.lowercased() {
			answer = .correct
		} else {
			answer = .incorrect
		}
		
		delegate?.answersReceiver(self, didAcceptAnswer: answer)
	}
}

// MARK: - UITextFieldDelegate
extension AnswersReceiver: UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
					replacementString string: String) -> Bool {
		guard state != .finish, configurator.currentInputViewType == .keyboard else {
			return false
		}
		
		let text = textField.text ?? ""
		
		if let range = Range(range, in: text) {
			let updatedText = text.replacingCharacters(in: range, with: string)
			state = updatedText.isEmpty ? .start : .receiving
		}
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if state == .receiving {
			handleAcceptedAnswer()
		} else if state == .finish {
			delegate?.answersReceiverReadyForNextQuestion(self)
		}
		return true
	}
}

// MARK: - SelectHeadwordInputViewDelegate
extension AnswersReceiver: SelectHeadwordViewProviderDelegate {
	
	func selectHeadwordViewProvider(_ provider: SelectHeadwordViewProvider,
									didSelect headword: String) {
		
		currentTextField?.text = headword
		handleAcceptedAnswer()
	}
}

// MARK: - ConstructHeadwordControllerDelegate
extension AnswersReceiver: ConstructHeadwordControllerDelegate {
	
	func constructHeadwordController(_ controller: ConstructHeadwordController,
									didSelectLetter letter: String) {
		
		if currentTextField?.hasText == false {
			currentTextField?.text = letter.capitalized
		} else {
			currentTextField?.text?.append(letter)
		}
		state = .receiving
	}
	
	func constructionDidComplete(by controller: ConstructHeadwordController) {
		handleAcceptedAnswer()
	}
}

// MARK: - LearningKeyboardAccessoryViewDelegate
extension AnswersReceiver: LearningKeyboardAccessoryViewDelegate {
	func accessoryView(_ accessoryView: LearningKeyboardAccessoryView,
						didSelectAction action: LearningKeyboardAccessoryView.Actions) {
		
		switch action {
		case .showAnswer:
			handleAcceptedAnswer()
			
		case .nextQuestion:
			delegate?.answersReceiverReadyForNextQuestion(self)
			
		case .restartAnswering:
			currentTextField?.text = nil
			state = .start
		}
	}
}
