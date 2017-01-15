//
//  Pco.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/14.
//  Copyright © 2017 Eonil. All rights reserved.
//

import Foundation

///
/// A collection of utility function for Pco.
///
/// Pco is an abbreviation for `Pseudo Coroutine`.
/// Pco provides a coroutine like concurrent execution
/// facility using system thread.
///
/// Originally intended name was `Process`, but it 
/// conflicts with `Foundation.Process`, and declined.
///
public enum Pco {
    public enum Panic {
        case error(Error)
    }
    ///
    /// Spawns a pco with pre-configured channels.
    /// 
    /// - Parameter body:
    ///     A function body.
    ///     You can throw an error only once.
    ///     Error throwing halts any on-going execution.
    ///     This function SHOULD NEVER return before the 
    ///     incoming/outgoing channels to be closed.
    ///
    /// - Note:
    ///     If you need to send multiple errors, it's more
    ///     likely to be a regular output signal rather
    ///     than an error. Consider making it as an output
    ///     signal intead of error.
    ///
    public static func spawn<I,O>(panic: @escaping (Panic) -> (), _ body: @escaping (_ incoming: PcoAnyIncomingChannel<I>, _ outgoing: PcoAnyOutgoingChannel<O>) throws -> ()) -> PcoIOChannelSet<I,O> {
        let incoming = PcoThreadChannel<I>()
        let outgoing = PcoThreadChannel<O>()
        Thread.detachNewThread {
            do {
                try body(PcoAnyIncomingChannel(incoming), PcoAnyOutgoingChannel(outgoing))
            }
            catch let e {
                panic(.error(e))
            }
//            assert(incoming.isClosed == true, "Function `body` SHOULD NEVER be returned before `incoming` channel to be closed.")
//            assert(outgoing.isClosed == true, "Function `body` MUST close `outgoing` channel before return.")
        }
        return PcoIOChannelSet(PcoAnyOutgoingChannel(incoming), PcoAnyIncomingChannel(outgoing))
    }
    ///
    /// Same with another version of `spawn` except this 
    /// calls global panic handler on panic.
    ///
    public static func spawn<I,O>(_ body: @escaping (_ incoming: PcoAnyIncomingChannel<I>, _ outgoing: PcoAnyOutgoingChannel<O>) throws -> ()) -> PcoIOChannelSet<I,O> {
        return spawn(panic: { Pco.panic($0) }, body)
    }
    ///
    /// Global panic handler.
    ///
    public static var panic: ((Panic) -> ()) = { fatalError("Panic `\($0)` in a Pco.") }
}
