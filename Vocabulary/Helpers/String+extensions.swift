//
//	Swift+extension.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 5/6/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

// MARK: - String -
extension String {
	
	func capitalizingFirstLetter() -> String {
		return prefix(1).uppercased() + dropFirst()
	}
	
	mutating func capitalizeFirstLetter() {
		self = self.capitalizingFirstLetter()
	}
	
	func englishWords(limit: Int) -> [String] {
		guard !hasPrefix("http") else { return [] }
		
		var words: [String] = []
		
		let englishWordCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'-"
		let forbiddenCharactersSet = CharacterSet(charactersIn: englishWordCharacters).inverted
		
		enumerateSubstrings(in: startIndex..<endIndex, options: [.byWords]) { (optionalWord, _, _, stop) in
			
			if let word = optionalWord,
				word.rangeOfCharacter(from: forbiddenCharactersSet) == nil {
				if word.count > 2 {
					words.append(word)
				}
			}
			if words.count >= limit {
				stop = true
			}
		}
		return words
	}
	
	func strikethroughText(with color: UIColor) -> NSAttributedString {
		let text = NSMutableAttributedString(string: self)
		let range = NSMakeRange(0, text.length)
		let strikethroughStyleValue = NSNumber(value: NSUnderlineStyle.thick.rawValue)
		
		text.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
		text.addAttribute(NSAttributedString.Key.strikethroughColor, value: color, range: range)
		text.addAttribute(
			NSAttributedString.Key.strikethroughStyle, value: strikethroughStyleValue, range: range
		)
		return text
	}
}
