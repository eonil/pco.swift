//
//  PThreadMutex.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//
//

import Foundation

///
/// https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/pthread_mutex_trylock.3.html
///
final class PThreadMutex {
    private var raw_mutex = pthread_mutex_t()
    ///
    /// https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/pthread_mutex_init.3.html#//apple_ref/doc/man/3/pthread_mutex_init
    ///
    init() {
        let r = pthread_mutex_init(&raw_mutex, nil)
        switch r {
        case 0:
            return
        case EAGAIN:
            fatalError("The system temporarily lacks the resources to create another mutex.")
        case EINVAL:
            fatalError("The value specified by attr is invalid.")
        case ENOMEM:
            fatalError("The process cannot allocate enough memory to create another mutex.")
        default:
            fatalError("Unknown error `\(r)` during pthread call.")
        }
    }
    ///
    /// https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/pthread_mutex_destroy.3.html#//apple_ref/doc/man/3/pthread_mutex_destroy
    ///
    deinit {
        let r = pthread_mutex_destroy(&raw_mutex)
        switch r {
        case 0:
            return
        case EBUSY:
            fatalError("Mutex is locked by a thread.")
        case EINVAL:
            fatalError("The value specified by mutex is invalid.")
        default:
            fatalError("Unknown error `\(r)` during pthread call.")
        }
    }
    ///
    /// https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/pthread_mutex_lock.3.html#//apple_ref/doc/man/3/pthread_mutex_lock
    ///
    func lock() {
        let r = pthread_mutex_lock(&raw_mutex)
        switch r {
        case 0:
            return
        case EDEADLK:
            fatalError("A deadlock would occur if the thread blocked waiting for mutex.")
        case EINVAL:
            fatalError("The value specified by mutex is invalid.")
        default:
            fatalError("Unknown error `\(r)` during pthread call.")
        }
    }
    ///
    /// https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/pthread_mutex_unlock.3.html#//apple_ref/doc/man/3/pthread_mutex_unlock
    ///
    func unlock() {
        let r = pthread_mutex_unlock(&raw_mutex)
        switch r {
        case 0:
            return
        case EINVAL:
            fatalError("The value specified by mutex is invalid.")
        case EPERM:
            fatalError("The current thread does not hold a lock on mutex.")
        default:
            fatalError("Unknown error `\(r)` during pthread call.")
        }
    }
    ///
    /// https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/pthread_mutex_trylock.3.html
    ///
    /// - Returns:
    ///     `true` if locked successfully.
    ///     `false` if locking failed.
    ///     This function always returns immediately.
    ///
    func tryLock() -> Bool {
        let r = pthread_mutex_trylock(&raw_mutex)
        switch r {
        case 0:
            return true // OK.
        case EBUSY:
            return false //
        case EINVAL:
            fatalError("The value specified by mutex is invalid.")
        default:
            fatalError("Unknown error `\(r)` during pthread call.")
        }
    }
}

