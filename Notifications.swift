//
//  Notifications.swift
//  Vocabulary
//
//  Created by Oleg  on 18.06.2023.
//  Copyright © 2023 Alexander Baraley. All rights reserved.
//

import Foundation
import NotificationCenter

class NotificationScheduler {
    let vocabularyStore: VocabularyStore = .init()
    let currentCenter = UNUserNotificationCenter.current()

    func fetchWord() -> [Word] {
        let fetchRequest = WordFetchRequestFactory.wordsForNotification()
        var words = vocabularyStore.wordsFrom(fetchRequest)


        words.shuffle()

        let randomWords = Array(words.prefix(15))

        return randomWords
    }

    func requestAuthorization() {
        currentCenter.requestAuthorization(
            options: [.badge, .sound, .alert],
            completionHandler:  { granted, erorr in

        })
    }

    func scheduleNotification() {
        setupNotification()
        let words = fetchWord()

        let baseTime = Date()
        let notificationInterval = 60

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
                identifier: WordNotification.categoryId,
                content: content,
                trigger: trigger
            )

            currentCenter.add(request)
        }
    }

    func setupNotification() {
        let rememberAction = UNNotificationAction(identifier: WordNotification.rememberId,
                                                  title: WordNotification.rememberId)
        let repeatAction = UNNotificationAction(identifier: WordNotification.repeatId,
                                                title: WordNotification.repeatId)

        let singleWordCategory = UNNotificationCategory(
            identifier: WordNotification.categoryId,
            actions: [rememberAction, repeatAction],
            intentIdentifiers: []
        )

        currentCenter.setNotificationCategories([singleWordCategory])
    }


    func handleActions(with identifier: String) {
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

enum WordNotification {
    static let categoryId  = "WordRepeat"
    static let rememberId = "Remember"
    static let repeatId = "Repeat"
}
