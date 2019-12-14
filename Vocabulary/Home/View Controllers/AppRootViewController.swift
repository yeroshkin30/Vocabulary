//
//  AppRootViewController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 05.12.2019.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class AppRootViewController: UITabBarController {

	private let vocabularyStore = VocabularyStore()

	private let showWordCollectionsBarButton = UIBarButtonItem(
		title: "Collections", style: .plain, target: self, action: #selector(showWordCollections)
	)

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .white
		setupViewControllers()
	}
}

// MARK: - Private
private extension AppRootViewController {

	var learningTabInitialViewController: LearningOptionsViewController {
		let learningStoryboard = UIStoryboard.storyboard(storyboard: .learning)

		guard let learningOptionsViewController = learningStoryboard.instantiateInitialViewController(creator: {
			LearningOptionsViewController(coder: $0, vocabularyStore: self.vocabularyStore)
		}) else { fatalError() }

		return learningOptionsViewController
	}

	var searchTabInitialViewController: SearchTabViewController {
		let searchStoryboard = UIStoryboard.storyboard(storyboard: .search)

		guard let searchViewController = searchStoryboard.instantiateInitialViewController(creator: {
			SearchTabViewController(coder: $0,
									vocabularyStore: self.vocabularyStore,
									searchStateModelController: SearchStateModelController())
		}) else { fatalError() }

		return searchViewController
	}

	var wordsTabInitialViewController: WordsTabViewController {
		let wordsStoryboard = UIStoryboard.storyboard(storyboard: .words)

		guard let wordsViewController = wordsStoryboard.instantiateInitialViewController(creator: {
			WordsTabViewController(coder: $0, vocabularyStore: self.vocabularyStore)
		}) else { fatalError() }

		return wordsViewController
	}

	func setupViewControllers() {
		let learningTabVC = tabNavigationController(with: learningTabInitialViewController)
		let searchTabVC = tabNavigationController(with: searchTabInitialViewController)
		let wordsTabVC = tabNavigationController(with: wordsTabInitialViewController)

		viewControllers = [learningTabVC, searchTabVC, wordsTabVC]
	}

	func tabNavigationController(with viewController: UIViewController) -> UINavigationController {
		let navVC = UINavigationController(rootViewController: viewController)
		navVC.navigationBar.prefersLargeTitles = true

		viewController.navigationItem.setLeftBarButton(showWordCollectionsBarButton, animated: false)

		return navVC
	}

	@objc
	func showWordCollections() {
		let mainStoryboard = UIStoryboard.storyboard(storyboard: .main)

		guard let wordCollectionsViewController = mainStoryboard.instantiateInitialViewController(creator: {
			WordCollectionsTableViewController(coder: $0, vocabularyStore: self.vocabularyStore)
		}) else { fatalError() }

		wordCollectionsViewController.wordCollectionDidSelectHandler = { [unowned self] in
			self.viewControllers?.forEach({
				if let navVC = $0 as? UINavigationController {
					navVC.viewControllers.first?.navigationItem.title = "\(currentWordCollectionInfo?.name ?? "Vocabulary")"
					wordCollectionsViewController.dismiss(animated: true, completion: nil)
				}
			})
		}

		let navVC = UINavigationController(rootViewController: wordCollectionsViewController)

		present(navVC, animated: true, completion: nil)
	}
}
