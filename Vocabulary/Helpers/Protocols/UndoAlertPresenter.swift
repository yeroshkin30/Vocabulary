//
//	UndoAlertPresenter.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 5/16/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol UndoAlertPresenter where Self: UIViewController {
	var vocabularyStore: VocabularyStore! { get set }
}

extension UndoAlertPresenter {
	
	func showUndoAlert() {
		let canRedo = vocabularyStore.context.undoManager?.canRedo ?? false
		let canUndo = vocabularyStore.context.undoManager?.canUndo ?? false
		
		guard canUndo || canRedo else { return }
		
		let alert = UIAlertController(title: "Last Changes", message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		if canUndo {
			alert.addAction(UIAlertAction(title: "Undo", style: .default, handler: handleAction(_:)))
		}
		if canRedo {
			alert.addAction(UIAlertAction(title: "Redo", style: .default, handler: handleAction(_:)))
		}
		present(alert, animated: true)
	}
	
	private func handleAction(_ action: UIAlertAction) {
		if action.title == "Undo" {
			self.vocabularyStore.context.undo()
		} else {
			self.vocabularyStore.context.redo()
		}
		self.vocabularyStore.saveChanges()
	}
}

extension WordCollectionsTableViewController: UndoAlertPresenter {}
extension ListOfWordsViewController: UndoAlertPresenter {}
