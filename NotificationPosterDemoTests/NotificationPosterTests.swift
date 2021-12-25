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

class NotificationPosterTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []
    private lazy var mockNotifications: [MockNotification] = {
        Array(1...10).map { element in
            MockNotification(objectValue: element)
        }
    }()
    
    class MockSubscriber {
        var counter: Int = 0
        
        init() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleNotification(_:)),
                name: UIApplication.userDidTakeScreenshotNotification,
                object: nil
            )
        }
        
        @objc func handleNotification(_ notification: Notification) {
            let log = OSLog(subsystem: "NotificationSubscriber",
                            category: "handleNotification")
            os_signpost(.begin, log: log, name: "Notification Received")
            counter += 1
            os_signpost(.end, log: log, name: "Notification Received")

        }
    }
        
    func testDemo() {
        let exp = expectation(description: #function)
        let sut = NotificationPoster.shared
        
        let mockSubscriber = MockSubscriber()
        XCTAssertEqual(mockSubscriber.counter, 0)
        
        let expectedValues = [true, false, false, true]
        
        sut.$isEmpty
            .collect(4)
            .print("sut.$notifications")
            .sink { receivedValues in
                XCTAssertEqual(receivedValues, expectedValues)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertEqual(mockSubscriber.counter, 10)
                    exp.fulfill()
                }
            }
            .store(in: &subscriptions)
        

        mockNotifications.forEach { mock in
            sut.post(notification: mock)
        }

        waitForExpectations(timeout: 5)
    }
}
