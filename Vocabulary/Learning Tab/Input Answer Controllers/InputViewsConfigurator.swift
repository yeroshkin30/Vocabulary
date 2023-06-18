//
//	InputViewsConfigurator.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/25/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData

protocol HeadwordInputViewProvider {
	var headword: String? { get set }
	var inputView: UIView { get }
}

class InputViewsConfigurator: NSObject {
	
	// MARK: - Initialization -
	
	private let headwordsSourceContext: NSManagedObjectContext
	
	init(context: NSManagedObjectContext) {
		self.headwordsSourceContext = context
		super.init()
	}
	
	// MARK: - Public properties
	
	weak var textFieldDelegate: AnswersReceiver?
	
	var state: AnswersReceiver.State = .start {
		didSet { answerAcceptanceStateDidChange() }
	}
	
	func setup(_ textField: UITextField, for word: Word) {
		textField.text = ""
		textField.delegate = textFieldDelegate
		textField.inputView = inputView(for: word)
		textField.inputAccessoryView = keyboardAccessoryView
	}
	
	// MARK: - Private properties
	
	private(set) var currentInputViewType: InputViewType = .keyboard
	
	// MARK: - Custom input views
	
	private lazy var selectHeadwordController: SelectHeadwordViewProvider = {
		let controller = SelectHeadwordViewProvider(context: headwordsSourceContext)
		controller.delegate = textFieldDelegate
		return controller
	}()
	
	private lazy var constructHeadwordController: ConstructHeadwordController = {
		let controller = ConstructHeadwordController()
		controller.delegate = textFieldDelegate
		return controller
	}()
	
	private lazy var keyboardAccessoryView: LearningKeyboardAccessoryView = {
		let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44.0)
		let accessoryView = LearningKeyboardAccessoryView(frame: frame)
		accessoryView.isTranslucent = false
		accessoryView.actionHandler = textFieldDelegate
		return accessoryView
	}()
	
	private func inputView(for word: Word) -> UIView? {
		switch word.learningStageDetail {
		case .select:
			currentInputViewType = .selectHeadword
			selectHeadwordController.headword = word.headword
			return selectHeadwordController.inputView
			
		case .construct:
			currentInputViewType = .constructHeadword
			constructHeadwordController.headword = word.headword
			return constructHeadwordController.inputView
			
		default:
			currentInputViewType = .keyboard
			return nil
		}
	}
	
	private func answerAcceptanceStateDidChange() {
		switch state {
		case .start:
			keyboardAccessoryView.viewMode = .showAnswerButtonAvailable
			
			if currentInputViewType == .constructHeadword {
				constructHeadwordController.restart()
			}
			
		case .receiving:
			keyboardAccessoryView.viewMode = .refreshButtonAvailable
			
		case .finish:
			keyboardAccessoryView.viewMode = .nextButtonAvailable
			
			if currentInputViewType == .constructHeadword {
				constructHeadwordController.headword = nil
			}
		}
	}
	
	// MARK: - Types
	
	enum InputViewType {
		case selectHeadword
		case constructHeadword
		case keyboard
		
		init(_ stage: Word.LearningStageDetail) {
			switch stage {
			case .select:		self = .selectHeadword
			case .construct:	self = .constructHeadword
			default:			self = .keyboard
			}
		}
	}
}
