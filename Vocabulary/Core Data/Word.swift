//
//	Word.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 4/18/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import CoreData

@objc(Word)
public class Word: NSManagedObject {
	
	public override func awakeFromInsert() {
		super.awakeFromInsert()
		examplesText = ""
		dateCreated = Date()
		nextTrainingDate = Date()
	}
	
	var learningStage: LearningStage {
		get { return LearningStage(rawValue: learningStageValue)! }
		set { assignLearningStage(newValue)	}
	}
	
	var learningStageDetail: LearningStageDetail {
		get {
			switch learningStage {
			case .reminding:	return .numberOfReminders(Int(learningStageDetailValue))
			default:			return LearningStageDetail(value: learningStageDetailValue)
			}
		}
		set {
			learningStageDetailValue = newValue.value
			updateNextTrainingDate()
		}
	}
	
	var examples: [String] {
		get { return examplesText.isEmpty ? [] : examplesText.components(separatedBy: "\n\n") }
		set { self.examplesText = newValue.joined(separator: "\n\n") }
	}
}

extension Word {
	
	@nonobjc public class func createFetchRequest() -> NSFetchRequest<Word> {
		return NSFetchRequest<Word>(entityName: "Word")
	}
	
	@NSManaged public var headword: String
	@NSManaged public var sentencePart: String
	@NSManaged public var definition: String
	@NSManaged public var dateCreated: Date
	@NSManaged private(set) var examplesText: String
	@NSManaged public var nextTrainingDate: Date?
	@NSManaged private(set) var learningStageValue: Int16
	@NSManaged private(set) var learningStageDetailValue: Int16
	@NSManaged public var wordCollection: WordCollection?
}

extension Word {
	
	enum LearningStage: Int16, CaseIterable {
		
		case unknown, repeating, reminding, learned
		
		static let count = 4
		
		static var names: [String] {
			return ["Unknown", "Repeating", "Reminding", "Learned"]
		}
		
		var name: String { return LearningStage.names[Int(self.rawValue)] }
	}
	
	enum LearningStageDetail {
		
		case none, select, construct, input, numberOfReminders(Int)
		
		fileprivate init(value: Int16) {
			switch value {
			case 0:		self = .select
			case 1:		self = .construct
			case 2:		self = .input
			default:	self = .none
			}
		}
		
		fileprivate var value: Int16 {
			switch self {
			case .none, .select:	return 0
			case .construct:		return 1
			case .input:			return 2
			case .numberOfReminders(let remindingTimes):
				return Int16(remindingTimes)
			}
		}
	}
	
	private func assignLearningStage(_ stage: Word.LearningStage) {
		switch stage {
		case .unknown, .learned:	learningStageDetail = .none
		case .repeating:			learningStageDetail = .select
		case .reminding:			learningStageDetail = .numberOfReminders(1)
		}
		learningStageValue = stage.rawValue
		updateNextTrainingDate()
	}
	
	func increaseLearningStage() {
		switch (learningStage, learningStageDetail) {
		case (.unknown, _):				assignLearningStage(.repeating)
		case (.repeating, .select):		learningStageDetail = .construct
		case (.repeating, .construct):	learningStageDetail = .input
		case (.repeating, .input):		assignLearningStage(.reminding)
			
		case (.reminding, .numberOfReminders(let number)):
			learningStageDetail = .numberOfReminders(number + 1)
			
		default:
			break
		}
	}
	
	func decreaseLearningStage() {
		
		switch (learningStage, learningStageDetail) {
		case (.repeating, .construct):		learningStageDetail = .select
		case (.repeating, .input):			learningStageDetail = .construct
			
		case (.reminding, .numberOfReminders(let number)) where number > 0:
			learningStageDetail = .numberOfReminders(0)
			
		default:
			assignLearningStage(.unknown)
		}
	}
	
	private func updateNextTrainingDate() {
//		No time interval, for tests
//		nextTrainingDate = Date(); return
		
		let calendar = Calendar.current
		
		let shuffleFactor = Int.random(in: 0...600)
		let numberOfDays: Int
		
		switch learningStage {
		case .unknown:				nextTrainingDate = dateCreated; return
		case .repeating:			numberOfDays = 1
		case .reminding:			numberOfDays = min(Int(learningStageDetailValue + 1) * 2, 14)
		case .learned:				return
		}
		
		let dateComponents = DateComponents(calendar: calendar,
											day: numberOfDays,
											second: shuffleFactor)
		
		nextTrainingDate = calendar.date(byAdding: dateComponents, to: Date())
	}
}
