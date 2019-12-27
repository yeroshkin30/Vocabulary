//
//  CurrentWordCollectionModelController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 17.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import Foundation

protocol CurrentWordCollectionInfoObserver: AnyObject {

	func currentWordCollectionDidChange(_ wordCollectionInfo: WordCollectionInfo?)
}

protocol CurrentWordCollectionInfoProvider {

	var wordCollectionInfo: WordCollectionInfo? { get }

	func addObserver(_ observer: CurrentWordCollectionInfoObserver)
	func removeObserver(_ observer: CurrentWordCollectionInfoObserver)
}

class CurrentWordCollectionModelController: CurrentWordCollectionInfoProvider {

	var wordCollectionInfo: WordCollectionInfo? { didSet { notifyObservers() } }

	// MARK: - Observation

	private var observations: [ObjectIdentifier: Observation] = [:]

	func addObserver(_ observer: CurrentWordCollectionInfoObserver) {
		let id = ObjectIdentifier(observer)
		observations[id] = Observation(observer: observer)
		observer.currentWordCollectionDidChange(wordCollectionInfo)
	}

	func removeObserver(_ observer: CurrentWordCollectionInfoObserver) {
		let id = ObjectIdentifier(observer)
		observations.removeValue(forKey: id)
	}

	private func notifyObservers() {
		observations.forEach { (id, observation) in
			if let observer = observation.observer {
				observer.currentWordCollectionDidChange(wordCollectionInfo)

			} else {
				observations.removeValue(forKey: id)
			}
		}
	}
}

private extension CurrentWordCollectionModelController {

	struct Observation {
        weak var observer: CurrentWordCollectionInfoObserver?
    }
}
