//
//	Entry.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 9/4/17.
//	Copyright © 2017 Alexander Baraley. All rights reserved.
//

import Foundation

struct Entry {
	var headword = ""
	var sentencePart = ""
	var definitions: [Definition] = []
	var expressions: [Expression] = []
}

struct Definition {
	var text = ""
	var category = ""
	var examples: [String] = []
	var seeAlso = ""
}

struct Expression {
	var text = ""
	var definitions: [Definition] = []
	var seeAlso = ""
}

extension Entry: Equatable {
	static func == (lhs: Entry, rhs: Entry) -> Bool {
		return	lhs.headword == rhs.headword &&
			lhs.sentencePart == rhs.sentencePart &&
			lhs.definitions.count == rhs.definitions.count &&
			lhs.expressions.count == rhs.expressions.count
	}
}

extension Definition: Equatable {
	static func == (lhs: Definition, rhs: Definition) -> Bool {
		return lhs.text == rhs.text
	}
}

extension Expression: Equatable {
	static func == (lhs: Expression, rhs: Expression) -> Bool {
		return	lhs.text == rhs.text &&
			lhs.definitions.count == rhs.definitions.count
	}
}
