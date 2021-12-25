//
//  NotificationPoster.swift
//  NotificationPosterDemo
//
//  Created by Adrian Bolinger on 12/24/21.
//

import Combine
import Foundation
#if DEBUG
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
    
    // FIXME: find a cleaner way to monitor contents of the array to broadcast when done
    @Published var arrayIsEmpty: Bool?
    
    /// Initializer is private because this is a singleton class.
    private init() {}
    
    /// Timer that is alive so long as there are elements in the `notifications` array.
    private var cancellable: AnyCancellable?
    
    // This is for the timer
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published private(set) var notifications: [MockNotification] = [] {
        willSet {
            // if the array is empty and about to receive a value
            if notifications.isEmpty && newValue.count == 1 {
                startNotificationTimer()
            }
        }
        
        didSet {
            if notifications.isEmpty {
                cancellable = nil
            }
        }
    }
    
    public func post(notification: MockNotification) {
        notifications.append(notification)
    }
    
    private func startNotificationTimer() {
        cancellable = Timer.publish(every: 0.1,
                                    tolerance: 0.1,
                                    on: .main,
                                    in: .common)
            .autoconnect()
            .sink(receiveValue: { object in
                let log = OSLog(subsystem: "NotificationPoster",
                                   category: "startNotificationTimer()")
                os_signpost(.begin, log: log, name: "post(notification:)")
                self.post(notification: self.notifications.removeFirst())
                os_signpost(.end, log: log, name: "post(notification:)")
            })
        
    }
}
