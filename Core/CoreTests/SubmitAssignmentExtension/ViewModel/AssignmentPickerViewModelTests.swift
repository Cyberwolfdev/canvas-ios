//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Combine
@testable import Core
import XCTest

class AssignmentPickerViewModelTests: CoreTestCase {
    private let mockService = MockAssignmentPickerListService()
    private var testee: AssignmentPickerViewModel!

    override func setUp() {
        super.setUp()
        testee = AssignmentPickerViewModel(service: mockService)
        environment.userDefaults?.reset()
    }

    func testAPIError() {
        mockService.mockResult = .failure("Custom error")
        testee.courseID = "failingID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .error("Custom error"))
    }

    func testAssignmentFetchSuccessful() {
        mockService.mockResult = .success([
            .init(id: "A2", name: "online upload", allowedExtensions: []),
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload", allowedExtensions: []),
        ]))
    }

    func testSameCourseIdDoesntTriggerRefresh() {
        mockService.mockResult = .success([
            .init(id: "A1", name: "online upload", allowedExtensions: []),
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload", allowedExtensions: []),
        ]))

        mockService.mockResult = .failure("Custom error")
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload", allowedExtensions: []),
        ]))
    }

    func testDefaultAssignmentSelection() {
        environment.userDefaults?.submitAssignmentID = "A2"
        mockService.mockResult = .success([
            .init(id: "A2", name: "online upload", allowedExtensions: []),
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertEqual(testee.selectedAssignment, .init(id: "A2", name: "online upload", allowedExtensions: []))
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload", allowedExtensions: []),
        ]))
        // Keep the assignment ID so if the user submits another attempt without starting the app we'll pre-select
        XCTAssertNotNil(environment.userDefaults?.submitAssignmentID)
    }

    func testCourseChangeRefreshesState() {
        mockService.mockResult = .success([
            .init(id: "A1", name: "online upload", allowedExtensions: []),
        ])
        testee.courseID = "successID"
        drainMainQueue()
        XCTAssertEqual(testee.state, .data([
            .init(id: "A1", name: "online upload", allowedExtensions: []),
        ]))

        testee.assignmentSelected(.init(id: "A1", name: "online upload", allowedExtensions: []))
        mockService.mockResult = .success([
            .init(id: "A2", name: "online upload", allowedExtensions: []),
        ])
        testee.courseID = "successID2"
        drainMainQueue()
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .data([
            .init(id: "A2", name: "online upload", allowedExtensions: []),
        ]))
    }

    func testPreviewInitializer() {
        let testee = AssignmentPickerViewModel(state: .loading)
        XCTAssertNil(testee.selectedAssignment)
        XCTAssertEqual(testee.state, .loading)
    }

    func testReportsAssignmentSelectionToAnalytics() {
        let analyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = analyticsHandler
        XCTAssertEqual(analyticsHandler.loggedEventCount, 0)

        testee.assignmentSelected(.init(id: "", name: "", allowedExtensions: []))

        XCTAssertEqual(analyticsHandler.loggedEventCount, 1)
        XCTAssertEqual(analyticsHandler.lastEventName, "assignment_selected")
        XCTAssertNil(analyticsHandler.lastEventParameters)
    }
}

class MockAssignmentPickerListService: AssignmentPickerListServiceProtocol {
    public private(set) lazy var result: AnyPublisher<APIResult, Never> = resultSubject.eraseToAnyPublisher()
    public var courseID: String? {
        didSet { resultSubject.send(mockResult ?? .failure("No mock result")) }
    }

    var mockResult: APIResult?
    private let resultSubject = PassthroughSubject<APIResult, Never>()
}
