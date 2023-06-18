//
//	UndoAlertPresenter.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 5/16/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

protocol UndoAlertPresenter where Self: UIViewController {
	var vocabularyStore: VocabularyStore { get }
}

extension UndoAlertPresenter {
	
	func showUndoAlert() {
		let canRedo = vocabularyStore.viewContext.undoManager?.canRedo ?? false
		let canUndo = vocabularyStore.viewContext.undoManager?.canUndo ?? false
		
		guard canUndo || canRedo else { return }
		
		let alert = UIAlertController(title: "Last Changes", message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		if canUndo {
			alert.addAction(UIAlertAction(title: "Undo", style: .default) { _ in
				self.vocabularyStore.viewContext.undo()
				self.vocabularyStore.saveChanges()
			})
		}
		if canRedo {
			alert.addAction(UIAlertAction(title: "Redo", style: .default) { _ in
				self.vocabularyStore.viewContext.redo()
				self.vocabularyStore.saveChanges()
			})
		}
		present(alert, animated: true)
	}
}

extension WordCollectionsViewController: UndoAlertPresenter {}
extension ListOfWordsViewController: UndoAlertPresenter {}
