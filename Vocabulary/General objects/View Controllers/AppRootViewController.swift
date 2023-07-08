//
//  AppRootViewController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 05.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class AppRootViewController: UITabBarController, SegueHandlerType {

	private lazy var vocabularyStore: VocabularyStore = .init()
	private let currentWordCollectionModelController: CurrentWordCollectionModelController = .init()

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .systemBackground
		setupViewControllers()
	}

	// MARK: - Navigation

	enum SegueIdentifier: String {
		case showWordCollections
	}

	@IBSegueAction
	private func makeWordCollectionsController(coder: NSCoder) -> WordCollectionsViewController? {
		let modelController: WordCollectionsModelController = .init(
			vocabularyStore: vocabularyStore,
			currentWordCollectionModelController: currentWordCollectionModelController
		)
		return WordCollectionsViewController(
			coder: coder,
			vocabularyStore: vocabularyStore,
			modelController: modelController
		)
	}
}

// MARK: - Private
private extension AppRootViewController {

	func setupViewControllers() {
		viewControllers?.forEach {
			guard let navVC: UINavigationController = $0 as? UINavigationController else { return }

			navVC.viewControllers.first?.navigationItem.leftBarButtonItem = UIBarButtonItem(
				title: "Collections", style: .plain, target: self, action: #selector(showWordCollections)
			)
            navVC.viewControllers.first?.navigationItem.rightBarButtonItem = setupNotifications()

			if let learningTabVC: LearningModesViewController = navVC.viewControllers.first as? LearningModesViewController {
				learningTabVC.vocabularyStore = vocabularyStore
				learningTabVC.currentWordCollectionInfoProvider = currentWordCollectionModelController
			}
			if let searchTabVC: SearchTabViewController = navVC.viewControllers.first as? SearchTabViewController {
				searchTabVC.vocabularyStore = vocabularyStore
				searchTabVC.searchStateModelController = SearchStateModelController()
				searchTabVC.currentWordCollectionInfoProvider = currentWordCollectionModelController
			}
			if let wordsTabVC: WordsTabViewController = navVC.viewControllers.first as? WordsTabViewController {
				wordsTabVC.vocabularyStore = vocabularyStore
				wordsTabVC.currentWordCollectionInfoProvider = currentWordCollectionModelController
			}
		}
	}

	@objc
	func showWordCollections() {
		performSegue(with: .showWordCollections, sender: nil)
	}

    @objc
    func setupNotifications() -> UIBarButtonItem {
        let notificationScheduler = NotificationScheduler(vocabularyStore: vocabularyStore)

        let repeatWords = UIAction(
            title: "Repeat words",
            handler: { _ in
                notificationScheduler.setupNotifications(with: .repeating)
            }
        )

        let remindWords = UIAction(
            title: "Remind Words",
            handler: { _ in
                notificationScheduler.setupNotifications(with: .reminding)
            }
        )
        let learnedWords = UIAction(
            title: "Learned Words",
            handler: { _ in
                notificationScheduler.setupNotifications(with: .learned)
            }
        )

        let menuItems = UIMenu(children: [repeatWords, remindWords, learnedWords])
        let menuButton = UIBarButtonItem(title: "Notification", image: nil, target: nil, action: nil, menu: menuItems)

        return menuButton
    }
}
