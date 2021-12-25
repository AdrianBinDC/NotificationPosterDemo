//
//  NotificationPosterTests.swift
//  NotificationPosterDemoTests
//
//  Created by Adrian Bolinger on 12/24/21.
//

@testable import NotificationPosterDemo
import Combine
import os.signpost
import XCTest

class MockSubscriber {
    @Published var counter: Int = 0
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init() {
        NotificationCenter.default
            .publisher(
                for: UIApplication.userDidTakeScreenshotNotification,
                   object: nil
            )
            .sink { _ in
                let log = OSLog(subsystem: "NotificationSubscriber",
                                category: "handleNotification")
                os_signpost(.begin, log: log, name: "Notification Received")
                self.counter += 1
                os_signpost(.end, log: log, name: "Notification Received")
            }
            .store(in: &subscriptions)
    }    
}

class NotificationPosterTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []
    private lazy var mockNotifications: [MockNotification] = {
        Array(1...10).map { element in
            MockNotification(objectValue: element)
        }
    }()
            
    func testDemo() {
        let isEmptyExp = expectation(description: "isEmpty")
        let sut = NotificationPoster.shared
        
        let counterExp = expectation(description: "counter")
        let mockSubscriber = MockSubscriber()
        XCTAssertEqual(mockSubscriber.counter, 0)
        
        let expectedIsEmptyValues = [true, false, false, true]
        
        sut.$isEmpty
            .collect(4)
            .print("sut.$notifications")
            .sink { receivedIsEmptyValues in
                XCTAssertEqual(receivedIsEmptyValues, expectedIsEmptyValues)
                isEmptyExp.fulfill()
            }
            .store(in: &subscriptions)
        
        mockSubscriber.$counter
            .collect(11)
            .sink { receivedCounts in
                XCTAssertEqual(receivedCounts, Array(0...10))
                counterExp.fulfill()
            }
            .store(in: &subscriptions)
        
        mockNotifications.forEach { mock in
            sut.post(notification: mock)
        }

        waitForExpectations(timeout: 5)
    }
}
