EonilPco
=============
2017/01/15
Hoon H.

[![Build Status](https://travis-ci.org/eonil/pco.swift.svg?branch=master)](https://travis-ci.org/eonil/pco.swift)

Provides a limited pseudo coroutine on top of `Foundation.Thread`.

This library requires macOS 10.12 or later. Customized Xcode project
is required to make it work until Swift Package Manager to work 
better. 

Why?
----

Applications are built with manyof concurrent executions.
For an example, every asynchronous operations are all concurrent 
executions.

Anyway, writing concurrent code in Swift is still so painful because
it does not provide a good way to express multiple concurrent 
executions. Ideal construct to write such concurrent execution is
coroutine, but we don't have it right now, so there are many 
workarounds.

- State machines.
- Threads.
- Bolts.
- Rx.
- Zewo coroutine.
- DSL.

They all have pros/cons, so we need to use a best one for each case.

State machines are simple, but it has too weak expressive power, 
so writing a complex logic is almost impossible. Especially for 
branching and loops. And if you need a sort of subroutine execution,
it becomes too complicated. Complex state machines almost look like
assembly programs. Though we can code everything using state-
machines, but I like to avoid state machine if possible.
Anyway, state machines are still good for very simple cases. 
Especially if it's literally been used just to management some 
"state" (or "phase"), it's actually quiet good.

Threads are almost complete solution. You can utilize your 
language's expressive power as is, pause/resume and call subroutines 
freely. But threads are expensive. Very expensive. In both of 
coding-time and run-time. When you code thread based code, you 
always have to care about data-races and synchronizations. At run-
time, creating a thread takes extra resources. Threading can be very
lightweight in theory, but it's actually heavy in reality, and more
importantly, Apple system hard limits number of threads in a 
process. So thread cannot be a universal solution.

Bolts/Rx are clever workarounds for this problem. Bolts deals with
serial asynchronous execution, and Rx tries to deal with loops and
branches. But they cannot pause/resume freely in a subroutine. 
This makes composition of subprograms harder. So usage of Bolts/Rx
are limited a sort of "pipelining" areas.

Zewo coroutine is a classical hack to C stack. This is clever and
likely to work, but it really cannot provide robustness without
proper compiler support. Though this is one of the ideal solution,
it cannot be used due to lack of robustness...

Choice
------
Concurrency in human facing applications is usually a flow-control 
issue rather than a throughput issue. Which means it doesn't 
require extreme scalability. So this library set these goals.

- abandon scalability
- utilize expressive power of user programming language
- avoid unstable hack.

This library just wraps thread features into something like 
Goroutines and Go-lang channels. This library does not provide hard 
memory segregation, and user need to take care of it. Thread 
constructs will create additional threads when needed, and Apple 
systems have some hard limits on number of threads in a process. 
I recommend creating less than 128 threads. It would be enough to
provide application flow control for each domains. Just accept this
limit like you avoid stack overflow. 

Why No GCD?
-----------
I once tried to build this with GCD. But it was hard becasue I am 
not expert onl GCD. It was easier to implement this only top of
plain thread. My major problem was lack of synchronization facility.
I have no idea how I can implement Go-lang's unbuffered channel 
behavior using GCD facilities. And GCD does not support Thread lock
facilities very well. Because many GCD queues can run on a thread,
thread lock usually produces deadlock, and it's too complicated to
avoid such deadlock. GCD has a bit more abstraction on top of 
thread, and I don't know the tricks to make it work.

Note
----
*macOS 10.12.2* on my MBP has hard limit in maximum number of threads.

- GCD: 512
- `Foundation.Thread`: 2048
- `pthread`: 2048

I haven't tested kernel API, but it should have similar limit.

Swift 4
-------
Chris Lattener explcitly declared an implmentation of Actor model
will be provided in Swift 4. I think this will become a proper, 
safe and scalable actor model, then this library will not be 
required anymore. I hope the day come ASAP.

The scheduled implementation of actor model is also one of the 
reason to write this library. Because code written in some actor
style can be ported into new actor model easily.

License
-------
Licensed under "MIT License".
