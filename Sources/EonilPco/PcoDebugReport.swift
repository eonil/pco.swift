//
//  PcoDebugReport.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//  Copyright © 2017 Eonil. All rights reserved.
//

internal enum PcoDebugReport {
//    case unclosedChannelOnDeinit(AnyObject)

    static var delegate: (PcoDebugReport) -> () = handlePcoReportDefault
    static func dispatch(_ r: PcoDebugReport) {
        delegate(r)
    }
}

private func handlePcoReportDefault(_ r: PcoDebugReport) {
//    switch r {
////    case .unclosedChannelOnDeinit(let ch):
////        fatalError("Unclosed channel discovered: \(ch)")
//    }
}
