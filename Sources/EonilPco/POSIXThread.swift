//
//  POSIXThreadMutex.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//
//

import Foundation

///
/// https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/pthread_mutex_trylock.3.html
///
final class POSIXThreadMutex {
    fileprivate var rawValue = pthread_mutex_t()
    ///
    /// https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/pthread_mutex_init.3.html#//apple_ref/doc/man/3/pthread_mutex_init
    ///
    init() {
        let r = pthread_mutex_init(&rawValue, nil)
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
        let r = pthread_mutex_destroy(&rawValue)
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
        let r = pthread_mutex_lock(&rawValue)
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
        let r = pthread_mutex_unlock(&rawValue)
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
        let r = pthread_mutex_trylock(&rawValue)
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



///
/// - macOS is a Unix 03.
///     http://images.apple.com/media/us/osx/2012/docs/OSX_for_UNIX_Users_TB_July2011.pdf
///     http://www.opengroup.org/openbrand/register/apple.htm
///
/// - PThread is a part of POSIX 1c.
///     https://en.wikipedia.org/wiki/POSIX_Threads
///
///
///
final class POSIXThreadCond {
    fileprivate var rawValue = pthread_cond_t()

    /// - SeeAlso:
    ///
    ///     man pthread_cond_init
    ///
    init() {
        let r = pthread_cond_init(&rawValue, nil)
        switch r {
        case 0:
            return
        case EINVAL:
            fatalError("The value specified by attr is invalid.")
        case ENOMEM:
            fatalError("The process cannot allocate enough memory to create another condition variable.")
        case EAGAIN:
            fatalError("The system temporarily lacks the resources to create another condition variable.")
        default:
            fatalError("Unknown error `\(r)` occurred while calling POSIX thread functions.")
        }
    }
    /// - SeeAlso:
    ///
    ///     man pthread_cond_destroy
    ///
    deinit {
        let r = pthread_cond_destroy(&rawValue)
        switch r {
        case 0:
            return
        case EINVAL:
            fatalError("The value specified by cond is invalid.")
        case EBUSY:
            fatalError("The variable cond is locked by another thread.")
        default:
            fatalError("Unknown error `\(r)` occurred while calling POSIX thread functions.")
        }
    }
    /// `pthread_cond_wait` -- wait on a condition variable
    ///
    /// The pthread_cond_wait() function atomically blocks the current thread
    /// waiting on the condition variable specified by cond, and releases the
    /// mutex specified by mutex.  The waiting thread unblocks only after another
    /// thread calls pthread_cond_signal(3), or pthread_cond_broadcast(3) with
    /// the same condition variable, and the current thread reacquires the lock
    /// on mutex.
    ///
    /// - SeeAlso:
    ///
    ///     man pthread_cond_wait
    ///
    /// - SeeAlso:
    ///     http://stackoverflow.com/questions/2763714/why-do-pthreads-condition-variable-functions-require-a-mutex
    ///
    func wait(mutex: POSIXThreadMutex) {
        let r = pthread_cond_wait(&rawValue, &mutex.rawValue)
        switch r {
        case 0:
            return
        case EINVAL:
            fatalError("The value specified by cond or the value specified by mutex is invalid.")
        default:
            fatalError("Unknown error `\(r)` occurred while calling POSIX thread functions.")
        }
    }
//    func wait(for duration: TimeInterval) {
//
//    }

    /// `pthread_cond_signal` -- unblock a thread waiting for a condition variable
    ///
    /// The `pthread_cond_signal()` function unblocks one thread waiting for the
    /// condition variable cond.
    ///
    /// - SeeAlso:
    ///
    ///     man pthread_cond_signal
    ///
    func signal() {
        let r = pthread_cond_signal(&rawValue)
        switch r {
        case 0:
            return
        case EINVAL:
            fatalError("The value specified by cond or the value specified by mutex is invalid.")
        default:
            fatalError("Unknown error `\(r)` occurred while calling POSIX thread functions.")
        }
    }

    /// `pthread_cond_broadcast` -- unblock all threads waiting for a condition
    /// variable
    ///
    /// The pthread_cond_broadcast() function unblocks all threads waiting for
    /// the condition variable cond.
    ///
    /// - SeeAlso:
    ///     
    ///     man pthread_cond_broadcast
    ///
    func broadcast() {
        let r = pthread_cond_signal(&rawValue)
        switch r {
        case 0:
            return
        case EINVAL:
            fatalError("The value specified by cond is invalid.")
        default:
            fatalError("Unknown error `\(r)` occurred while calling POSIX thread functions.")
        }
    }
}
