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
		let location = NSPersistentContainer.defaultDirectoryURL()
		
		let fm = FileManager.default
		
		let fileName = "Vocabulary"
		let fileExtensions = ["sqlite", "sqlite-shm", "sqlite-wal"]
		
		for fileExtension in fileExtensions {
			if let source = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
				let destination = location.appendingPathComponent(source.lastPathComponent)
				try? fm.copyItem(at: source, to: destination)
			}
		}
	}
}
