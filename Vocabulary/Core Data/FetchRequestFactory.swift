//
//	FetchRequestFactory.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 7/5/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import CoreData

typealias WordsRequestParameter = (
	learningStage: Word.LearningStage?, wordCollection: WordCollection?, regardNextTrainingDate: Bool
)

struct FetchRequestFactory {
	
	static func requestForWords(with parameters: WordsRequestParameter) -> NSFetchRequest<Word> {
		let fetchRequest = Word.createFetchRequest()
		fetchRequest.fetchBatchSize = 10
		fetchRequest.returnsObjectsAsFaults = false
		
		fetchRequest.predicate = predicateForWords(with: parameters)
		
		return fetchRequest
	}
	
	static func predicateForWords(with parameters: WordsRequestParameter) -> NSPredicate {
		
		var predicates: [NSPredicate] = []
		
		if let stage = parameters.learningStage {
			let stageFormat = "\(#keyPath(Word.learningStageValue)) == \(String(stage.rawValue))"
			predicates.append(NSPredicate(format: stageFormat))
		}
		if let wordCollection = parameters.wordCollection {
			let format = "\(#keyPath(Word.wordCollection.dateCreated)) == %@"
			predicates.append(NSPredicate(format: format, wordCollection.dateCreated as NSDate))
		}
		if parameters.regardNextTrainingDate {
			let nextTrainingDateFormat = "\(#keyPath(Word.nextTrainingDate)) < %@"
			predicates.append(NSPredicate(format: nextTrainingDateFormat, NSDate()))
		}
		return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
	}
}

enum LearningTypeFetchRequest {
	case unknown, repetition, remind
	
	func request() -> NSFetchRequest<Word> {
		let parameters: WordsRequestParameter
		let fetchRequest: NSFetchRequest<Word>
		
		switch self {
		case .unknown:
			parameters = (.unknown, currentWordCollection, false)
			fetchRequest = FetchRequestFactory.requestForWords(with: parameters)
			fetchRequest.sortDescriptors = [
				NSSortDescriptor(key: #keyPath(Word.nextTrainingDate), ascending: true)
			]
		case .repetition:
			parameters = (.repeating, currentWordCollection, true)
			fetchRequest = FetchRequestFactory.requestForWords(with: parameters)
			fetchRequest.sortDescriptors = [
				NSSortDescriptor(key: #keyPath(Word.nextTrainingDate), ascending: true)
			]
		case .remind:
			parameters = (.reminding, currentWordCollection, true)
			fetchRequest = FetchRequestFactory.requestForWords(with: parameters)
			fetchRequest.sortDescriptors = [
				NSSortDescriptor(key: #keyPath(Word.nextTrainingDate), ascending: true)
			]
		}
		
		return fetchRequest
	}
}
