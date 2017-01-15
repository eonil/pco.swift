//
//  PcoMappingTests.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//
//

import Foundation
import XCTest
@testable import EonilPco

class PcoMappingTests: XCTestCase {

    func testPcoChannelMappedTransfer() {
        let exp = expectation(description: "ok")
        let w1 = PcoThreadSignalWaiter()
        let w2 = PcoThreadSignalWaiter()
        let ch = PcoThreadChannel<Int>()
        let ch1 = ch.map({ "\($0)abc" })
        Thread.detachNewThread {
            ch.send(111)
            ch.send(nil)
            w1.signal()
        }
        Thread.detachNewThread {
            var first = true
            for s in ch1 {
                XCTAssert(first)
                XCTAssert(s == "111abc")
                w2.signal()
                first = false
            }
        }
        w1.wait()
        w2.wait()
        exp.fulfill()
        waitForExpectations(timeout: 4) { (e: Error?) in
            XCTAssert(e == nil)
        }
    }
    func testPcoChannelBufferedMappedTransfered() {
        let exp = expectation(description: "ok")
        let w1 = PcoThreadSignalWaiter()
        let w2 = PcoThreadSignalWaiter()
        let ch = PcoThreadChannel<Int>()
        let ch1 = ch.bufferedMap({ (_ s: Int) -> ([String]) in
            if s == 0 {
                return []
            }
            else {
                return ["aaa", "bbb", "ccc"]
            }
        })
        Thread.detachNewThread {
            ch.send(111)
            ch.send(nil)
            w1.signal()
        }
        Thread.detachNewThread {
            var counter = 0
            for s in ch1 {
                switch counter {
                case 0:
                    XCTAssert(s == "aaa")
                case 1:
                    XCTAssert(s == "bbb")
                case 2:
                    XCTAssert(s == "ccc")
                default:
                    XCTFail()
                }
                counter += 1
            }
            XCTAssert(counter == 3)
            w2.signal()
        }
        w1.wait()
        w2.wait()
        exp.fulfill()
        waitForExpectations(timeout: 4) { (e: Error?) in
            XCTAssert(e == nil)
        }
    }
//
//    func test1() {
//        let sema = DispatchSemaphore(value: 0)
//        let (c1, e1) = Pco.spawn { (_ c: PcoAnyIncomingChannel<Int>, _ e: PcoAnyOutgoingChannel<Int>) in
//            c.receive { s in
//                print(s)
//            }
//            e.send(222)
//            e.close()
//        }
//        c1.send(111)
//        c1.close()
//        e1.receive { s in
//            print(s)
//        }
//        sema.wait()
//    }
//    func test1() {
//        let (c, e) = LineBashProcess.spawn()
//        c.send(.stdin("echo AAA"))
//        e.receive { s in
//            print(s)
//        }
//    }

}
