//
//  Notifications.swift
//  Vocabulary
//
//  Created by Oleg  on 18.06.2023.
//  Copyright © 2023 Alexander Baraley. All rights reserved.
//

import Foundation
import NotificationCenter

class NotificationScheduler: NSObject {
    let notificationCenter = UNUserNotificationCenter.current()
    let vocabularyStore: VocabularyStore

    init(vocabularyStore: VocabularyStore) {
        self.vocabularyStore = vocabularyStore
    }

    func setupNotifications() {
        authorizeIfNeeded { granted in
            guard granted else { return }
            self.createNotificationCategory()
            self.scheduleNotifications()
        }
    }

    // MARK: - Authorization
    private func authorizeIfNeeded(completion: @escaping (Bool) -> ()) {
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .sound], completionHandler: { (granted, _) in
                    completion(granted)
                })
            case .denied, .provisional, .ephemeral:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }

    private func fetchWords() -> [Word] {
        let fetchRequest = WordFetchRequestFactory.wordsForNotification()
        let words = vocabularyStore.wordsFrom(fetchRequest).shuffled()
        let randomWords = Array(words.prefix(30))

        return randomWords
    }

    private func scheduleNotifications() {
        let words = fetchWords()

        let baseTime = Date()
        let notificationInterval = 60 * 20

        for (index, word) in words.enumerated() {
            let notificationTime = baseTime.addingTimeInterval(TimeInterval(index * notificationInterval))

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                              from: notificationTime), repeats: false)

            let content = UNMutableNotificationContent()
            content.title = word.headword
            content.body = word.definition
            content.categoryIdentifier = WordNotification.categoryId

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            notificationCenter.add(request)
        }
    }

    private func createNotificationCategory() {
        notificationCenter.delegate = self
        let rememberAction = UNNotificationAction(identifier: WordNotification.rememberId,
                                                  title: WordNotification.rememberId)
        let repeatAction = UNNotificationAction(identifier: WordNotification.repeatId,
                                                title: WordNotification.repeatId)

        let singleWordCategory = UNNotificationCategory(
            identifier: WordNotification.categoryId,
            actions: [rememberAction, repeatAction],
            intentIdentifiers: []
        )

        notificationCenter.setNotificationCategories([singleWordCategory])
    }


    private func handleActions(with identifier: String) {
        switch identifier {
        case WordNotification.rememberId:
            print("remember")
        case WordNotification.repeatId:
            print("repeat")
        default:
            break
        }
    }
}

extension NotificationScheduler: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleActions(with: response.actionIdentifier)
        completionHandler()
    }
}

enum WordNotification {
    static let categoryId  = "WordRepeat"
    static let rememberId = "Remember"
    static let repeatId = "Repeat"
}


