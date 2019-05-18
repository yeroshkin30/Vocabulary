//
//	WordCollection+CoreDataProperties.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/18/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//
//

import Foundation
import CoreData

@objc(WordCollection)
public class WordCollection: NSManagedObject {
	
	public override func awakeFromInsert() {
		super.awakeFromInsert()
		dateCreated = Date()
	}
}

extension WordCollection {
	
	@nonobjc public class func createFetchRequest() -> NSFetchRequest<WordCollection> {
		return NSFetchRequest<WordCollection>(entityName: "Collection")
	}
	
	@NSManaged public var name: String
	@NSManaged public var dateCreated: Date
	@NSManaged public var words: NSSet?
	
}

// MARK: Generated accessors for words
extension WordCollection {
	
	@objc(addWordsObject:)
	@NSManaged public func addToWords(_ value: Word)
	
	@objc(removeWordsObject:)
	@NSManaged public func removeFromWords(_ value: Word)
	
	@objc(addWords:)
	@NSManaged public func addToWords(_ values: NSSet)
	
	@objc(removeWords:)
	@NSManaged public func removeFromWords(_ values: NSSet)
	
}
