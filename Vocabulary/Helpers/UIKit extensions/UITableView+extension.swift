//
//	UITableView+extension.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/10/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import CoreData.NSFetchedResultsController

// MARK: - Reusability
extension UITableView {
	func registerNibForCell<T: UITableViewCell>(_: T.Type) {

        let identifier = String(describing: T.self)

		register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
	}
	
	func dequeueCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
		let identifier = String(describing: T.self)
		guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
			fatalError("Could not dequeue cell with \(identifier)")
		}
		return cell
	}
	
	func indexPathForRow(with view: UIView) -> IndexPath? {
		let point = self.convert(CGPoint.zero, from: view)
		return self.indexPathForRow(at: point)
	}
}

// MARK: - NSFetchedResultsController

typealias FetchedDataChange = (type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)

extension UITableView {

	func handleChanges(_ changes: [FetchedDataChange]) {
		performBatchUpdates({
			changes.forEach() { (change) in
				switch change.type {
				case .insert:	insertRows(at: [change.newIndexPath!], with: .automatic)
				case .delete:	deleteRows(at: [change.indexPath!], with: .automatic)
				case .update:	reloadRows(at: [change.indexPath!], with: .automatic)
				case .move:		moveRow(at: change.indexPath!, to: change.newIndexPath!)
				@unknown default: fatalError()
				}
			}
		})
	}
}
