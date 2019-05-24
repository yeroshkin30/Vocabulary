//
//	FetchRequestFactory.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 7/5/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import CoreData

typealias WordsRequestParameters = (
	learningStage: Word.LearningStage?, wordCollectionID: NSManagedObjectID?, regardNextTrainingDate: Bool
)

struct FetchRequestFactory {
	
	enum LearningType {
		case remembering, repetition, reminding
	}
	
	static func requestForWords(with parameters: WordsRequestParameters) -> NSFetchRequest<Word> {
		let fetchRequest = Word.createFetchRequest()
		fetchRequest.fetchBatchSize = 10
		fetchRequest.returnsObjectsAsFaults = false
		
		fetchRequest.predicate = predicateForWords(with: parameters)
		
		return fetchRequest
	}
	
	static func predicateForWords(with parameters: WordsRequestParameters) -> NSPredicate {
		
		var predicates: [NSPredicate] = []
		
		if let stage = parameters.learningStage {
			let stageFormat = "\(#keyPath(Word.learningStageValue)) == \(String(stage.rawValue))"
			predicates.append(NSPredicate(format: stageFormat))
		}
		if let wordCollectionID = parameters.wordCollectionID {
			let format = "\(#keyPath(Word.wordCollection)) == %@"
			predicates.append(NSPredicate(format: format, wordCollectionID))
		}
		if parameters.regardNextTrainingDate {
			let nextTrainingDateFormat = "\(#keyPath(Word.nextTrainingDate)) < %@"
			predicates.append(NSPredicate(format: nextTrainingDateFormat, NSDate()))
		}
		return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
	}
	
	static func fetchRequest(for learningType: LearningType) -> NSFetchRequest<Word> {
		let parameters: WordsRequestParameters
		
		let objectID = currentWordCollectionInfo?.objectID
		
		switch learningType {
		case .remembering:		parameters = (.unknown, objectID, false)
		case .repetition:		parameters = (.repeating, objectID, true)
		case .reminding:		parameters = (.reminding, objectID, true)
		}
		
		let fetchRequest = requestForWords(with: parameters)
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(Word.nextTrainingDate), ascending: true)
		]
		return fetchRequest
	}
}
