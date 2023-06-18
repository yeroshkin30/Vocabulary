//
//  Notifications.swift
//  Vocabulary
//
//  Created by Oleg  on 18.06.2023.
//  Copyright © 2023 Alexander Baraley. All rights reserved.
//

import Foundation
import NotificationCenter

class NotificationPermission {

    let vocabularyStore: VocabularyStore = .init()
    let center = UNUserNotificationCenter.current()


    func fetchWord() {
        
    }

    func requestAuthorization() {
        center.requestAuthorization(
            options: [.badge, .sound, .alert],
            completionHandler:  { granted, erorr in

        })
    }

    func scheduleNotification(with word: Word) {
        let content = UNMutableNotificationContent()
        content.title = word.headword
        content.body = word.definition

        let timeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

        let request = UNNotificationRequest(identifier: "WordRepeat", content: content, trigger: timeIntervalTrigger)

        center.add(request)
    }
}
