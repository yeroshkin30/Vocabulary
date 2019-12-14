//
//	AppDelegate.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 2/12/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions
		launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		if DefaultDataProvider.isVocabularyEmpty() {
			DefaultDataProvider.loadDefaultVocabulary()
		}

		let appRootViewController = AppRootViewController()

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = appRootViewController
		window?.makeKeyAndVisible()

		return true
	}
}
