//
//  PcoTests.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//
//

import Foundation
import XCTest
@testable import EonilPco

class PcoTests: XCTestCase {
    func testPcoThreadSignalWaiter() {
        let d1 = measureDuration {
            let w1 = PcoThreadSignalWaiter()
            Thread.detachNewThread {
                Thread.sleep(forTimeInterval: 2)
                w1.signal()
            }
            w1.wait()
        }
        XCTAssert(d1 > 1.9)
    }
    func testPcoThreadChannelTransfer() {
        let d1 = measureDuration {
            let ch = PcoThreadChannel<Int>()
            Thread.detachNewThread {
                Thread.sleep(forTimeInterval: 2)
                ch.send(111)
            }
            let r = ch.receive()
            XCTAssert(r == 111)
        }
        XCTAssert(d1 > 1.9)
    }
    func testPcoThreadChannelTransferMany() {
        let n = 1024
        let ch = PcoThreadChannel<Int>()
        Thread.detachNewThread {
            for i in 0..<n {
                ch.send(i)
                print("send: \(i)")
            }
        }
        for i in 0..<n {
            let r = ch.receive()
            XCTAssert(r == i)
            print("recv: \(i)")
        }
    }
    func testPcoThreadChannelClosing() {
        let ch = PcoThreadChannel<Int>()
        Thread.detachNewThread {
            ch.send(111)
            ch.send(222)
            ch.send(333)
            ch.send(nil)
            ch.send(nil)
            ch.send(nil)
        }
        XCTAssert(ch.receive() == 111)
        XCTAssert(ch.receive() == 222)
        XCTAssert(ch.receive() == 333)
        XCTAssert(ch.receive() == nil)
        XCTAssert(ch.receive() == nil)
        XCTAssert(ch.receive() == nil)
    }
    private func testPcoThreadChannelTransferringManySignalsWithManyThreads(_ print: @escaping (String) -> () = naivePrint) {
        let ch = PcoThreadChannel<Int>()
        let c1 = 37
        let c2 = 11
        let n = 1024
        let senderCompletionCounter = ADHOC_AtomicInt(0)
        for j in 0..<c1 {
            Thread.detachNewThread {
                for i in 0..<n {
                    let k = i * c1 + j
                    ch.send(k)
                    print("send\(j): \(k)")
                }
                senderCompletionCounter.increment()
                if senderCompletionCounter.state == c1 {
                    print("Last value sent. Closes channel to receivers to continue without deadlock.")
                    ch.send(nil)
                    print("Channel closed. Any further sendings will cause a crash.")
                }
            }
        }
        let w1 = PcoThreadSignalWaiter()
        let lck = NSLock()
        var collected = [Int]()
        func collect(ks: [Int]) {
            Thread.detachNewThread {
                print("collect started.")
                lck.lock()
                collected.append(contentsOf: ks)
                print("collected.count == \(collected.count)")
                XCTAssert(collected.count <= c1 * n)
                if collected.count == c1 * n {
                    w1.signal()
                }
                lck.unlock()
                print("collect ended.")
            }
        }
        for j in 0..<c2 {
            Thread.detachNewThread {
                var rs = [Int]()
                let mult = c1 / c2 + 1
                for _ in 0..<(n * mult) {
                    print("recv\(j): gonna wait..")
                    if let r = ch.receive() {
                        print("recv\(j): \(r)")
                        rs.append(r)
                    }
                    else {
                        print("recv\(j): channel closed. ignore taking..")
                    }
                }
                collect(ks: rs)
            }
        }
        w1.wait()
        XCTAssert(collected.sorted() == Array(0..<c1 * n), "collected (count: \(collected.count)) is not 0..<\(c1 * n)")
    }
    func testPcoThreadChannelTransferringManySignalsWithManyThreads0001Time() {
        testPcoThreadChannelTransferringManySignalsWithManyThreads()
    }
//    func testPcoThreadChannelTransferringManySignalsWithManyThreads1024Times() {
//        for i in 0..<32 {
//            print("hard test session\(i) started.")
//            testPcoThreadChannelTransferringManySignalsWithManyThreads() { _ in }
//            print("hard test session\(i) ended.")
//        }
//    }
    func testChannelSequence() {
        let exp = expectation(description: "done")
        let w1 = PcoThreadSignalWaiter()
        let w2 = PcoThreadSignalWaiter()
        let ch1 = PcoThreadChannel<Int>()
        let n = 1024
        Thread.detachNewThread {
            for i in 0..<n {
                ch1.send(i)
            }
            ch1.send(nil) // Close it!.
            w1.signal()
        }
        Thread.detachNewThread {
            var collected = [Int]()
            for i in ch1 {
                collected.append(i)
            }
            XCTAssert(collected == Array(0..<n))
            w2.signal()
        }
        w1.wait()
        w2.wait()
        exp.fulfill()
        waitForExpectations(timeout: 60)
    }
}

private func naivePrint(_ s: String) {
    print(s)
}
