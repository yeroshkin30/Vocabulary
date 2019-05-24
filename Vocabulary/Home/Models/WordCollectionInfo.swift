//
//  WordCollectionInfo.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 5/24/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import CoreData

struct WordCollectionInfo: Equatable {
	let name: String
	let dateCreated: Date
	let objectID: NSManagedObjectID
	
	init(_ wordCollection: WordCollection) {
		name = wordCollection.name
		dateCreated = wordCollection.dateCreated
		objectID = wordCollection.objectID
	}
}
