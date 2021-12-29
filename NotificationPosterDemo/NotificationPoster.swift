//
//  NotificationPoster.swift
//  NotificationPosterDemo
//
//  Created by Adrian Bolinger on 12/24/21.
//

import Combine
import Foundation
#if DEBUG
import UIKit
import os.signpost
#endif

struct MockNotification {
    let objectValue: Int
}

class NotificationPoster {
    /**
     `NotificationPoster` is initialized as a `shared` intance because it will be alive for
     the lifetime of the app, publishing notifications from `BluetoothFramework`.
     */
    static let shared = NotificationPoster()
    
    @Published private(set) var notificationQueue: [MockNotification] = []
    @Published private(set) var isEmpty: Bool = true
    
    /// Timer that is alive so long as there are elements in the `notifications` array.
    private var cancellable: AnyCancellable?
    
    // This is for the timer
    private var subscriptions: Set<AnyCancellable> = []
    
    let delayInterval: TimeInterval = 0.05
            
    /// Initializer is private because this is a singleton class.
    private init() {
        configurePublisher()
    }
        
    public func post(notification: MockNotification) {
        notificationQueue.append(notification)
    }
    
    
    /**
        `configurePublisher()` configures the `notifications` publisher.
     
     `NotificationPoster` is initialized as a singleton.
     - Upon initialization, the queue is empty
     - When a notification is `post(notification:)` is called, the notification is appended to a queue, NOT posted.
     
     The `notifications` array is a `Publisher` and when it's updated, the number of elements in the queue is observed by this method.
    
     If the queue has one element, a timer is activated to post the notifications every 0.05 seconds. The timer will remain active until the elements in the queue are cleared, at which point the timer will nilled out.
     */
    private func configurePublisher() {
        $notificationQueue
            .sink { notifications in
                switch notifications.count {
                case 0:
                    // cancel timer
                    self.cancellable = nil
                    self.isEmpty = true
                case 1:
                    // start timer
                    self.cancellable = Timer.publish(every: self.delayInterval,
                                                     tolerance: self.delayInterval * 0.5,
                                                     on: .main,
                                                     in: .common)
                        .autoconnect()
                        .sink(receiveValue: { _ in
                            self.startNotificationTimer()
                        })
                    
                    self.isEmpty = false
                default:
                    // do nothing, as the timer is already firing
                    break
                }
            }
            .store(in: &subscriptions)
    }
    
    private func startNotificationTimer() {
        let log = OSLog(subsystem: "NotificationPoster",
                        category: "startNotificationTimer()")
        os_signpost(.begin, log: log, name: "post(notification:)")
        let mockNotification = notificationQueue.removeFirst()
        let realNotification = Notification(name: UIApplication.userDidTakeScreenshotNotification)
        DispatchQueue.main.async {
            NotificationCenter.default.post(realNotification)
        }
        os_signpost(.end, log: log, name: "post(notification:)")
    }
}
