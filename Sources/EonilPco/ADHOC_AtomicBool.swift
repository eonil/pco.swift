//
//  ADHOC_AtomicBool.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/14.
//  Copyright © 2017 Eonil. All rights reserved.
//

import Foundation

///
/// Slow, but the only sane way to get atomicity for now in Swift 3...
///
final class ADHOC_AtomicBool {
    private let lock = NSLock()
    private var value = false
    init() {
    }
    init(_ newState: Bool) {
        state = newState
    }
    var state: Bool {
        get {
            let returningValue: Bool
            lock.lock()
            returningValue = value
            lock.unlock()
            return returningValue
        }
        set {
            lock.lock()
            value = newValue
            lock.unlock()
        }
    }
}
