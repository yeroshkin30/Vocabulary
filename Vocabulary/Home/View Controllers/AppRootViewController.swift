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

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .white
		setupViewControllers()
	}

	private func setupViewControllers() {
		viewControllers = [
			learningTabViewController()
		]
	}

	private func learningTabViewController() -> UIViewController {
		let learningStoryboard = UIStoryboard.storyboard(storyboard: .learning)

		guard let learningTypesViewController = learningStoryboard.instantiateInitialViewController(creator: {
			LearningTypesViewController(coder: $0, vocabularyStore: self.vocabularyStore)
		}) else {
			fatalError()
		}

		let viewController = UINavigationController(rootViewController: learningTypesViewController)
		viewController.navigationBar.prefersLargeTitles = true
		return viewController
	}
}
