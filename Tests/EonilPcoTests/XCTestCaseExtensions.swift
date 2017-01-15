//
//  XCTestCaseExtensions.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//
//

import Foundation
import XCTest

extension XCTestCase {
    func waitForExpectations(timeout: TimeInterval) {
        waitForExpectations(timeout: timeout) { (_ e: Error?) in
            XCTAssert(e == nil, "error: \(e!)")
        }
    }
}
