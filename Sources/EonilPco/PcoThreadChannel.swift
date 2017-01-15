//
//  PcoThreadChannel.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//
//

import Foundation

private let EMPTY = 0
private let SEND_DONE = 1
private let RECV_DONE = 2

///
/// A channel which is implemented using Cocoa `Thread` and lock facilities.
///
/// - Warning:
///     Take care when you use this channel with GCD queues.
///     Channel may cause deadlock because many serial GCD queues
///     can run in one thread.
///     Basically, just DO NOT use this channel to synchronize
///     multiple GCD queues. Use this only for explicit thread
///     which are spawned by `Foundation.Thread`.
///     It's unclear how this would work with `pthread` stuffs,
///     but I think it would be fine.
///
final class PcoThreadChannel<T>: PcoChannel {
    private let sendLock = NSLock()
    private let recvLock = NSLock()
    private let phase = NSConditionLock(condition: EMPTY)
    private var slot = T?.none
    private let is_open_flag_store = ADHOC_AtomicBool(true)

    func send(_ signal: T?) {
        guard is_open_flag_store.state else { return precondition(signal == nil, "You cannot send a non-nil value on a closed channel.") }
        sendLock.lock()
        phase.lock(whenCondition: EMPTY)
        slot = signal
        phase.unlock(withCondition: SEND_DONE)
        // Cannot exit before receiving done.
        phase.lock(whenCondition: RECV_DONE)
        phase.unlock(withCondition: EMPTY)
        if signal == nil {
            is_open_flag_store.state = false
            // At this point, some receivers can be waiting.
            while phase.tryLock(whenCondition: EMPTY) || phase.tryLock(whenCondition: RECV_DONE) {
                // Let them go...
                phase.unlock(withCondition: SEND_DONE)
            }
        }
        sendLock.unlock()
    }
    func receive() -> T? {
        guard is_open_flag_store.state else { return nil }
        recvLock.lock()
        let r: T?
        if is_open_flag_store.state {
            // Cannot enter before sending done.
            phase.lock(whenCondition: SEND_DONE)
            r = slot
            phase.unlock(withCondition: RECV_DONE)
        }
        else {
            r = nil
        }
        recvLock.unlock()
        return r
    }
    func makeIterator() -> AnyIterator<T> {
        return AnyIterator { [weak self] () -> T? in
            guard let ss = self else { return nil }
            return ss.receive()
        }
    }
}
