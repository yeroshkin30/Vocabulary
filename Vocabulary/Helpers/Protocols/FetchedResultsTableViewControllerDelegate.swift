//
//	FetchedResultsTableViewControllerDelegate.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 5/7/19.
//	Copyright © 2019 Alexander Baraley. All rights reserved.
//

import CoreData
import UIKit

protocol FetchedResultsTableViewControllerDelegate: NSFetchedResultsControllerDelegate {
	typealias DataChange =	(
		type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?
	)
	
	var dataChanges: [DataChange] { get set }
}

extension FetchedResultsTableViewControllerDelegate where Self: UITableViewController {
	
	func handleWordsChanges() {
		tableView.performBatchUpdates({
			dataChanges.forEach() { (change) in
				switch change.type {
				case .insert:	tableView.insertRows(at: [change.newIndexPath!], with: .automatic)
				case .delete:	tableView.deleteRows(at: [change.indexPath!], with: .automatic)
				case .update:	tableView.reloadRows(at: [change.indexPath!], with: .automatic)
				case .move:		tableView.moveRow(at: change.indexPath!, to: change.newIndexPath!)
				@unknown default: fatalError()
				}
			}
		})
		dataChanges.removeAll()
	}
}
