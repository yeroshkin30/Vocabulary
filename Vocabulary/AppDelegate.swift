//
//	AppDelegate.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 2/12/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
    let notifScheduler = NotificationScheduler()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions
		launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		if VocabularyStore.isPersistentStoreEmpty {
            VocabularyStore.loadDefaultVocabulary()
		}

        UNUserNotificationCenter.current().delegate = self
        notifScheduler.requestAuthorization()
        notifScheduler.scheduleNotification()

		return true
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		if let newPasteBoardString: String = UIPasteboard.general.string?.removingBooksAppExcerpt() {
			UIPasteboard.general.string = newPasteBoardString
		}
	}
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        notifScheduler.handleActions(with: response.actionIdentifier)
        completionHandler()
    }
}
