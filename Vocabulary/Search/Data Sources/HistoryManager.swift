//
//	HistoryManager.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 9/29/17.
//	Copyright © 2017 Alexander Baraley. All rights reserved.
//

import Foundation

private let savedWordsLimitNumber = 10

class HistoryManager {
	
	// MARK: - Private
	
	private let filePath: String = {
		let documentDerictory = FileManager.default.urls(for: .documentDirectory,
														in: .userDomainMask).first!
		let archiveURL = documentDerictory.appendingPathComponent("requestedWords")
		return archiveURL.path
	}()
	
	private lazy var words: [String] = {
		guard let data = FileManager.default.contents(atPath: filePath) else { return [] }
		
		let decoder = JSONDecoder()
		
		return (try? decoder.decode([String].self, from: data)) ?? []
	}()
	
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
	
	// MARK: - Public
	
	var allWords: [String] { return words }
	var numberOfWords: Int { return words.count }
	var isEmpty: Bool { return words.isEmpty }
	
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
	
	subscript(index: Int) -> String? {
		guard index >= 0 && index < words.count else { return nil }
		return words[index]
	}
}
