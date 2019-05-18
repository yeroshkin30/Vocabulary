//
//	LearningKeyboardAccessoryView.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 6/6/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

protocol LearningKeyboardAccessoryViewDelegate: AnyObject {
	func accessoryView(_ accessoryView: LearningKeyboardAccessoryView,
						didSelectAction action: LearningKeyboardAccessoryView.Actions)
}

class LearningKeyboardAccessoryView: UIToolbar {
	
	enum ViewMode {
		case empty, showAnswerButtonAvailable, nextButtonAvailable, refreshButtonAvailable
	}
	
	enum Actions {
		case showAnswer, nextQuestion, restartAnswering
	}
	
	weak var actionHandler: LearningKeyboardAccessoryViewDelegate?
	
	var viewMode: ViewMode = .empty {
		didSet { updateViewItems() }
	}
	
	// MARK: - View items
	
	private lazy var showButton: UIBarButtonItem = {
		return UIBarButtonItem(image: #imageLiteral(resourceName: "eye"), style: .plain, target: self,
								action: #selector(showButtonAction(_:)))
	}()
	
	private lazy var nextButton: UIBarButtonItem = {
		return UIBarButtonItem(image: #imageLiteral(resourceName: "next"), style: .plain, target: self,
								action: #selector(nextButtonAction(_:)))
	}()
	
	private lazy var refreshButton: UIBarButtonItem = {
		return UIBarButtonItem(image: #imageLiteral(resourceName: "undo"), style: .plain, target: self,
								action: #selector(refreshButtonAction(_:)))
	}()
	
	private lazy var flexibleSpace: UIBarButtonItem = {
		return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
	}()
	
	// MARK: - Actions
	
	@objc private func nextButtonAction(_ sender: UIBarButtonItem) {
		actionHandler?.accessoryView(self, didSelectAction: .nextQuestion)
	}
	
	@objc private func showButtonAction(_ sender: UIBarButtonItem) {
		actionHandler?.accessoryView(self, didSelectAction: .showAnswer)
	}
	
	@objc private func refreshButtonAction(_ sender: UIBarButtonItem) {
		actionHandler?.accessoryView(self, didSelectAction: .restartAnswering)
	}
	
	// MARK: - Helpers
	
	private func updateViewItems() {
		switch viewMode {
		case .empty:						items = []
		case .showAnswerButtonAvailable:	items = [showButton, flexibleSpace]
		case .nextButtonAvailable:			items = [flexibleSpace, nextButton]
		case .refreshButtonAvailable:		items = [showButton, flexibleSpace, refreshButton]
		}
	}
	
}
