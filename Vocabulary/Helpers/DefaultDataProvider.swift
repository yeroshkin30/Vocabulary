//
//	DefaultDataProvider.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 5/2/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import CoreData

class DefaultDataProvider {
	
	static func isVocabularyEmpty() -> Bool {
		let location = NSPersistentContainer.defaultDirectoryURL()
		
		let fm = FileManager.default
		let content = try? fm.contentsOfDirectory(at: location, includingPropertiesForKeys: nil)
		
		return content?.isEmpty == true
	}
	
	static func loadDefaultVocabulary() {
		
	}
}
