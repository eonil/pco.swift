//
//  PcoSignalWaiter.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//  Copyright © 2017 Eonil. All rights reserved.
//

import Foundation

/// `wait`s until some other thread `signal`s.
///
/// This object is one-time-use-only. Do not re-use this object.
///
/// - Note:
///     This does not have **spurious wake-up**.
///
/// - Note:
///
///     http://pubs.opengroup.org/onlinepubs/009604599/functions/pthread_cond_signal.html
///     http://stackoverflow.com/questions/8594591/why-does-pthread-cond-wait-have-spurious-wakeups
///
public final class PcoThreadSignalWaiter {
    private let mutex = POSIXThreadMutex()
    private let cond = POSIXThreadCond()
    private var signaled = false
    private var waiting = false

    public func signal() {
        mutex.lock()
        precondition(signaled == false, unavailableErrorMessage)
        signaled = true
        mutex.unlock()
        cond.signal()
    }
    public func wait() {
        mutex.lock()
        precondition(waiting == false, unavailableErrorMessage)
        waiting = true
        while signaled == false {
            //
            // This can be a spurious wake-up. (wrong wake-up without signaling)
            // Always check the flags to avoid bug.
            //
            cond.wait(mutex: mutex)
        }
        mutex.unlock()
    }
}

private let unavailableErrorMessage = "This waiter is one-time-use-only. You cannot re-use this object. Create a new object instead of re-using."
