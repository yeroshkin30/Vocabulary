//
//	UICollectionView+extension.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/10/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UICollectionView {
	
	func registerNibForCell<T: UICollectionViewCell>(_: T.Type) {
		let nib = UINib(nibName: T.stringIdentifier, bundle: nil)
		register(nib, forCellWithReuseIdentifier: T.stringIdentifier)
	}
	
	func registerNibForSupplementaryView<T: UICollectionReusableView>(_: T.Type, ofKind kind: String) {
		let nib = UINib(nibName: T.stringIdentifier, bundle: nil)
		register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.stringIdentifier)
	}
	
	func dequeueCell<T:UICollectionViewCell>(indexPath: IndexPath) -> T {
		let identifier = T.stringIdentifier
		
		let bareCell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
		guard let cell = bareCell as? T else {
			fatalError( "Failed to dequeue a cell with identifier \(identifier)")
		}
		return cell
	}
	
	func dequeueSupplementaryView<T:UICollectionReusableView>(of kind: String,
																at indexPath: IndexPath) -> T {
		let identifier = T.stringIdentifier
		
		let bareView = dequeueReusableSupplementaryView(
			ofKind: kind, withReuseIdentifier: identifier, for: indexPath
		)
		guard let supplementaryView = bareView as? T else {
			fatalError("Failed to dequeue a supplementary view with identifier \(identifier)")
		}
		return supplementaryView
	}
}
