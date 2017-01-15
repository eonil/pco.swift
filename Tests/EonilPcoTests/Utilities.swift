//
//  Utilities.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/15.
//
//

import Foundation

func measureDuration(_ f: () -> ()) -> TimeInterval {
    let startTimepoint = Date()
    f()
    let endTimepoint = Date()
    let duration = endTimepoint.timeIntervalSince(startTimepoint)
    return duration
}
