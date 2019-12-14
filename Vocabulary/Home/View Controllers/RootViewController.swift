//
//  RootViewController.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 5/21/19.
//  Copyright © 2019 Alexander Baraley. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
	
	private lazy var navigationVC = UINavigationController(nibName: nil, bundle: nil)
	
	private lazy var wordCollectionsVC = UIStoryboard(storyboard: .main)
		.instantiateViewController() as WordCollectionsTableViewController
	
	private lazy var homeVC = UIStoryboard(storyboard: .main)
		.instantiateViewController() as HomeViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViewControllers()
		add(navigationVC)
	}
	
	private func setupViewControllers() {
		let vocabularyStore = VocabularyStore()
		
		homeVC.vocabularyStore = vocabularyStore
		
		navigationVC.navigationBar.prefersLargeTitles = true
		navigationVC.setViewControllers([wordCollectionsVC, homeVC], animated: false)
	}
	
	private func showHomeViewController() {
		navigationVC.pushViewController(homeVC, animated: true)
	}
}
