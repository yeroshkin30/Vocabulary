//
//	EntriesParser.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 9/4/17.
//	Copyright © 2017 Alexander Baraley. All rights reserved.
//

import Foundation

class EntriesParserDelegate: NSObject {
	
	enum AcceptableElement: String {
		case none, entry_list, entry
		case suggestion
		case hw, fl, def, dro
		case dt, dre, un, sl, ssl
		case vi, it, phrase
		case sx, dx, dxt
		case snote
	}
	
	var acceptingCharacters = false
	var acceptingExpression = false
	var acceptingIt = false
	var acceptingPhrase = false
	var acceptingUsageNote = false
	
	var currentElement = AcceptableElement.none
	var elementToEndSkipping = ""
	
	var suggestions: [String]!
	
	var entries: [Entry]!
	
	var definitions: [Definition]!
	var examples: [String]!
	
	var entry: Entry?
	var aDefinition: Definition!
	var expression: Expression!
	
	var usageNote = ""
	var category = ""
	var anExample = ""
	
	func parseEntriesFrom(_ data: Data) -> EntriesParsingResult? {
		let parser = XMLParser(data: data)
		parser.delegate = self
		
		guard parser.parse() else {
			return nil
		}
		
		if let entries = entries, !entries.isEmpty {
			return .entries(entries)
		} else if let suggestions = suggestions, !suggestions.isEmpty {
			return .suggestions(suggestions)
		} else {
			return nil
		}
	}
}

// MARK: - XMLParserDelegate
extension EntriesParserDelegate: XMLParserDelegate {
	
	func parserDidStartDocument(_ parser: XMLParser) {
		entry = Entry()
		suggestions = []
		entries = []
		definitions = []
		examples = []
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
				qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
		
		guard let element = AcceptableElement.init(rawValue: elementName),
			elementToEndSkipping.isEmpty else {
				acceptingCharacters = false
				currentElement = .none
				if elementToEndSkipping.isEmpty {
					elementToEndSkipping = elementName
				}
				return
		}
		
		acceptingCharacters = true
		
		switch element {
		case .entry:
			entry = Entry()
		case .def:
			definitions = []
		case .dro:
			expression = Expression()
			acceptingExpression = true
		case .dt:
			aDefinition = Definition()
			examples = []
		case .un:
			acceptingUsageNote = usageNote.isEmpty
		case .vi:
			anExample = ""
		case .it:
			acceptingIt = true
			return
		case .phrase:
			acceptingPhrase = true
			return
		case .snote:
			return
		default:
			break
		}
		
		currentElement = element
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		guard acceptingCharacters else { return }
		
		switch currentElement {
		case .suggestion:
			suggestions.append(string.capitalized)
		case .hw:
			if string != " " {
				entry?.headword += string.replacingOccurrences(of: "*", with: "").capitalized
			}
		case .fl:
			entry?.sentencePart = string
		case .dt:
			aDefinition.text += definitionTextFrom(string, capitalize: aDefinition.text.isEmpty)
			
		case .un:
			if acceptingUsageNote {
				usageNote += definitionTextFrom(string, capitalize: true)
			}
		case .ssl, .sl:
			category += category.isEmpty ? string : ", \(string)"
		case .dre:
			expression.text += string.capitalizingFirstLetter()
		case .vi:
			anExample += string
		case .sx:
			aDefinition.seeAlso = string
		case .dxt:
			if let seeAlso = expression?.seeAlso, seeAlso.isEmpty {
				expression?.seeAlso = string
			}
		default:
			break
		}
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String,
				namespaceURI: String?, qualifiedName qName: String?) {
		
		guard let tag = AcceptableElement.init(rawValue: elementName),
			elementToEndSkipping.isEmpty else {
				if elementToEndSkipping == elementName	{
					elementToEndSkipping = ""
				}
				return
		}
		
		switch tag {
		case .entry:
			saveEntry()
		case .def:
			saveDefinitions()
		case .dro:
			saveExpression()
			acceptingExpression = false
		case .dt:
			aDefinition.text = aDefinition.text.trimmingCharacters(in: .whitespacesAndNewlines)
			saveDefinition()
		case .un:
			aDefinition.examples = examples
		case .vi:
			if !anExample.isEmpty {
				let example = anExample.capitalizingFirstLetter()
				examples.append(example)
			}
		case .it:
			acceptingIt = false
		case .phrase:
			acceptingPhrase = false
		default:
			currentElement = .none
		}
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		print(parseError.localizedDescription)
	}
}

// MARK: - Helpers
extension EntriesParserDelegate {
	
	private func definitionTextFrom(_ string: String, capitalize: Bool) -> String {
		
		let characterSet = CharacterSet(charactersIn: ":\n")
		
		var text = string
			.trimmingCharacters(in: characterSet)
			.replacingOccurrences(of: " :", with: ".\n")
			.replacingOccurrences(of: "(", with: "")
			.replacingOccurrences(of: ")", with: "")
		
		if capitalize {
			text = text
				.components(separatedBy: "\n")
				.map { $0.capitalizingFirstLetter() }
				.joined(separator: "\n")
		}
		return acceptingIt ? "\"\(text)\"" : text
	}
	
	private func saveEntry() {
		let hasDefinitions = !entry!.definitions.isEmpty
		let hasExpressions = !entry!.expressions.isEmpty
		
		if hasExpressions {
			let _ = entry?.expressions.partition(by: { $0.definitions.isEmpty })
		}
		if hasDefinitions || hasExpressions {
			entries.append(entry!)
		}
	}
	
	private func saveDefinitions() {
		if acceptingExpression {
			expression.definitions = definitions
		} else {
			entry?.definitions = definitions
		}
	}
	
	private func saveDefinition() {
		let hasText = !aDefinition.text.isEmpty
		let hasSeeAlso = !aDefinition.seeAlso.isEmpty
		let hasUsageNote = !usageNote.isEmpty
		
		if !hasText && hasUsageNote {
			aDefinition.text = usageNote
		}
		
		if hasText || hasSeeAlso || hasUsageNote {
			aDefinition.examples = examples
			aDefinition.category = category
			definitions.append(aDefinition)
		}
		usageNote = ""
		category = ""
		aDefinition = Definition()
	}
	
	private func saveExpression() {
		guard let expression = expression else { return }
		let hasText = !expression.text.isEmpty
		let hasDefinitions = !expression.definitions.isEmpty
		let hasSeeAlso = !expression.seeAlso.isEmpty
		
		if hasText && (hasDefinitions || hasSeeAlso) {
			entry?.expressions.append(expression)
		}
	}
}
