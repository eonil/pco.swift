//
//  PcoIOChannelSet.swift
//  EonilPco
//
//  Created by Hoon H. on 2017/01/14.
//  Copyright © 2017 Eonil. All rights reserved.
//

public typealias PcoIOChannelSet<Incoming,Outgoing> = (command: PcoAnyOutgoingChannel<Incoming>, event: PcoAnyIncomingChannel<Outgoing>)
