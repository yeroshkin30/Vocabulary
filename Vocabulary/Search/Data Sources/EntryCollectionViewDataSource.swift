//
//	EntryCollectionViewDataSource.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 1/24/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class EntryCollectionViewDataSource: NSObject, UICollectionViewDataSource {
	
	private let entry: Entry
	private let viewMode: EntryCollectionViewController.ViewMode
	
	init(entry: Entry, viewMode: EntryCollectionViewController.ViewMode) {
		self.entry = entry
		self.viewMode = viewMode
	}
	
	private lazy var collectionViewData = ViewData(entry: entry, viewMode: viewMode)
	
	// MARK: - UICollectionViewDataSource
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return collectionViewData.numberOfSections
	}
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return collectionViewData.numberOfItems(inSection: section)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueCell(indexPath: indexPath) as DefinitionCollectionViewCell
		let definition = collectionViewData.definitionData(for: indexPath)
		cell.viewData = DefinitionCollectionViewCell.ViewData(definition: definition)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
						viewForSupplementaryElementOfKind kind: String,
						at indexPath: IndexPath) -> UICollectionReusableView {
		
		let view = collectionView.dequeueSupplementaryView(of: kind,
															at: indexPath) as DefinitionsCollectionViewHeader
		view.viewData = collectionViewData.sectionViewData(for: indexPath.section)
		return view
	}
}

extension EntryCollectionViewDataSource {
	
	struct ViewData {
		
		private let sectionsViewData: [DefinitionsCollectionViewHeader.ViewData]
		private let definitionsData: [Int: [Definition]]
		
		init(entry: Entry, viewMode: EntryCollectionViewController.ViewMode) {
			
			switch viewMode {
			case .definitions:
				sectionsViewData = [DefinitionsCollectionViewHeader.ViewData(entry: entry)]
				definitionsData = [0: entry.definitions]
				
			case .expressions:
				var newSectionsData: [DefinitionsCollectionViewHeader.ViewData] = []
				var newDefinitionsViewData: [Int: [Definition]] = [:]
				
				for (index, expression) in entry.expressions.enumerated() {
					let collectionViewData = DefinitionsCollectionViewHeader.ViewData(expression: expression)
					
					newSectionsData.append(collectionViewData)
					newDefinitionsViewData[index] = expression.definitions
				}
				
				sectionsViewData = newSectionsData
				definitionsData = newDefinitionsViewData
			}
		}
		
		var numberOfSections: Int {
			return sectionsViewData.count
		}
		
		func numberOfItems(inSection section: Int) -> Int {
			return definitionsData[section]?.count ?? 0
		}
		
		func sectionViewData(for section: Int) -> DefinitionsCollectionViewHeader.ViewData {
			return sectionsViewData[section]
		}
		
		func definitionData(for indexPath: IndexPath) -> Definition {
			let section = definitionsData[indexPath.section]
			
			return section![indexPath.item]
		}
	}
}
