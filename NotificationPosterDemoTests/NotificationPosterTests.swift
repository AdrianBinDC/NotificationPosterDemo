//
//  NotificationPosterTests.swift
//  NotificationPosterDemoTests
//
//  Created by Adrian Bolinger on 12/24/21.
//

@testable import NotificationPosterDemo
import Combine
import XCTest

class NotificationPosterTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []
    private lazy var mockNotifications: [MockNotification] = {
        Array(1...10).map { element in
            MockNotification(objectValue: element)
        }
    }()
    
    func testDemo() {
//        let exp = expectation(description: #function)
        let sut = NotificationPoster.shared
        
//        sut.$arrayIsEmpty
//            .collect(2)
//            .sink { collectedValues in
//                print(collectedValues)
//                exp.fulfill()
//            }
//            .store(in: &subscriptions)
//        
//        mockNotifications.forEach { mock in
//            sut.post(notification: mock)
//        }
        
        waitForExpectations(timeout: 2)
    }
}
