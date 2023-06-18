//
//	HistoryModelController.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 9/29/17.
//	Copyright © 2017 Alexander Baraley. All rights reserved.
//

import Foundation

private let savedWordsLimitNumber: Int = 10

class HistoryModelController {
	
	// MARK: - Public
	
	var allWords: [String] 	{ return words }
	var numberOfWords: Int 	{ return words.count }
	var isEmpty: Bool 		{ return words.isEmpty }

	var historyDataDidChangeHandler: (() -> Void)?
	
	func saveWord(_ word: String) {
		if let index = words.firstIndex(of: word) {
			words.remove(at: index)
		}
		if words.count == savedWordsLimitNumber {
			words.removeLast()
		}
		words.insert(word, at: 0)
		saveHistory()
	}
	
	func word(at index: Int) -> String? {
		return self[index]
	}
	
	func deleteWord(at index: Int) {
		words.remove(at: index)
		saveHistory()
	}
	
	func clearHistory() {
		words = []
		saveHistory()
	}

	init() {
		loadWords()
	}
	
	subscript(index: Int) -> String? {
		guard index >= 0 && index < words.count else {
			return nil
		}
		return words[index]
	}

	// MARK: - Private

	private let filePath: String = {
		let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		return documentDirectory.appendingPathComponent("requestedWords").path
	}()

	private var words: [String] = [] {
		didSet {
			historyDataDidChangeHandler?()
		}
	}

	private func loadWords() {
		if let data = FileManager.default.contents(atPath: filePath) {
			let decoder = JSONDecoder()
			words = (try? decoder.decode([String].self, from: data)) ?? []

		} else {
			words = []
		}
	}
	
	private func saveHistory() {
		let encoder = JSONEncoder()
		do {
			let data = try encoder.encode(words)
			if FileManager.default.fileExists(atPath: filePath) {
				try FileManager.default.removeItem(atPath: filePath)
			}
			FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
		} catch {
			fatalError(error.localizedDescription)
		}
	}
}
