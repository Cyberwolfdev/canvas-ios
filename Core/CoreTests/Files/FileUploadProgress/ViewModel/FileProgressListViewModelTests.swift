//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import XCTest
import CoreData

class FileProgressListViewModelTests: CoreTestCase {
    private var context: NSManagedObjectContext { UploadManager.shared.viewContext }
    private var testee: FileProgressListViewModel!

    override func setUp() {
        super.setUp()
        testee = FileProgressListViewModel(batchID: "testBatch")
    }

    func testUploadingState() {
        makeFile()
        makeFile()
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading Zero KB of 20 bytes", progress: 0))
    }

    func testOneFileFinishedOtherIsUploading() {
        let file1 = makeFile()
        file1.id = "uploadedId"
        file1.bytesSent = file1.size
        makeFile()
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 10 bytes of 20 bytes", progress: 0.5))
    }

    func testOneFileFailedOtherIsUploading() {
        let file1 = makeFile()
        file1.uploadError = "error"
        file1.bytesSent = 5
        let file2 = makeFile()
        file2.bytesSent = 5
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 10 bytes of 20 bytes", progress: 0.5))
    }

    func testOneFileFailedOtherSucceeded() {
        let file1 = makeFile()
        file1.bytesSent = 5
        file1.uploadError = "error"
        let file2 = makeFile()
        file2.bytesSent = 10
        file2.id = "uploadedId"
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .failed)
    }

    func testBothFilesSucceeded() {
        let file1 = makeFile()
        file1.bytesSent = 10
        file1.id = "uploadedId"
        let file2 = makeFile()
        file2.bytesSent = 10
        file2.id = "uploadedId"
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .success)
    }

    func testUpdatesProgress() {
        let file = makeFile()
        saveFiles()
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading Zero KB of 10 bytes", progress: 0))

        let uiRefreshExpectation = expectation(description: "UI refresh trigger received")
        uiRefreshExpectation.expectedFulfillmentCount = 2
        let uiRefreshObserver = testee.objectWillChange.sink { _ in
            uiRefreshExpectation.fulfill()
        }
        file.bytesSent = 1
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 1 byte of 10 bytes", progress: 0.1))

        uiRefreshObserver.cancel()
    }

    func testCancelDialogProperties() {
        testee.cancel(env: environment, controller: WeakViewController())
        wait(for: [router.showExpectation], timeout: 0.1)

        guard let alert = router.presented as? UIAlertController else {
            XCTFail("No cancel dialog.")
            return
        }

        XCTAssertEqual(alert.title, "Cancel Submission?")
        XCTAssertEqual(alert.message, "This will cancel and delete your upload.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Yes")
        XCTAssertEqual(alert.actions[0].style, .destructive)
        XCTAssertEqual(alert.actions[1].title, "No")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }

    func testCancelDialogConfirmation() {
        let presentingViewController = UIViewController()
        testee.cancel(env: environment, controller: WeakViewController(presentingViewController))

        guard let alert = router.presented as? UIAlertController else {
            XCTFail("No cancel dialog.")
            return
        }

        (alert.actions[0] as? AlertAction)!.handler!(alert.actions[0])
        XCTAssertTrue(uploadManager.cancelWasCalled)
        XCTAssertEqual(uploadManager.canceledBatchID, "testBatch")
        XCTAssertEqual(router.dismissed, presentingViewController)
    }

    @discardableResult
    private func makeFile() -> File {
        let file = context.insert() as File
        file.batchID = "testBatch"
        file.size = 10
        file.filename = "file"
        file.setUser(session: environment.currentSession!)
        return file
    }

    private func saveFiles() {
        try! UploadManager.shared.viewContext.save()
    }
}
