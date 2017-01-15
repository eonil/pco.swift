//
//  POSIXSemaphore.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//
//

import Foundation
import Darwin
import Darwin.sys

///
/// - Note:
///     Why System V interface? Because POSIX interface has been deprecated in macOS...
///
/// - References:
///     http://www.ibm.com/developerworks/library/l-semaphore/
///
final class SystemVSemaphore {
    private var raw_value = sem_t()

    init() {

    }
}
