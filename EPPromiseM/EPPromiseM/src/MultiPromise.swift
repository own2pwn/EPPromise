//
//  MultiPromise.swift
//  EPPromiseM
//
//  Created by Evgeniy on 24/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
#endif

/// Could be fulfilled multiple times with different values
/// Calls then chain as fulfills
public final class MultiPromise<Value> {
    // MARK: - Members

    private let lockQueue = DispatchQueue(label: "own2pwn.core.promise-lock")

    private let execWorker = DispatchQueue(label: "own2pwn.core.promise-worker", attributes: .concurrent)

    private var state: State<Value>

    private var callbacks: [Callback<Value>] = []

    // MARK: - Interface

    public func fulfill(_ value: Value) {
        updateState(.fulfilled(value))
    }

    public func reject(_ error: Error) {
        updateState(.rejected(error))
    }

    // MARK: - Transform

    /// FlatMap
    @discardableResult
    public func then<NewValue>(_ transform: @escaping (Value) throws -> MultiPromise<NewValue>) -> MultiPromise<NewValue> {
        return MultiPromise<NewValue>(queue: execWorker) { filler, rejector in
            let onFulfill = { (value: Value) -> Void in
                do {
                    try transform(value).then(worker: self.execWorker, filler, rejector)
                } catch {
                    rejector(error)
                }
            }

            self.addCallback(for: self.execWorker, onFulfilled: onFulfill, onRejected: rejector)
        }
    }

    /// Map
    @discardableResult
    public func then<NewValue>(_ transform: @escaping (Value) throws -> NewValue) -> MultiPromise<NewValue> {
        return then { (value: Value) -> MultiPromise<NewValue> in
            do {
                return MultiPromise<NewValue>(value: try transform(value))
            } catch {
                return MultiPromise<NewValue>(error: error)
            }
        }
    }

    @discardableResult
    public func then(_ onFulfilled: @escaping (Value) -> Void) -> MultiPromise<Value> {
        return then(onFulfilled, { _ in })
    }

    @discardableResult
    public func then(_ onFulfilled: @escaping (Value) -> Void, _ onRejected: @escaping (Error) -> Void) -> MultiPromise<Value> {
        addCallback(for: execWorker, onFulfilled: onFulfilled, onRejected: onRejected)

        return self
    }

    @discardableResult
    public func then(worker: ExecutionContext, _ onFulfilled: @escaping (Value) -> Void) -> MultiPromise<Value> {
        return then(worker: worker, onFulfilled, { _ in })
    }

    @discardableResult
    public func then(worker: ExecutionContext, _ onFulfilled: @escaping (Value) -> Void, _ onRejected: @escaping (Error) -> Void) -> MultiPromise<Value> {
        addCallback(for: worker, onFulfilled: onFulfilled, onRejected: onRejected)

        return self
    }

    @discardableResult
    public func finalize(_ onFulfilled: @escaping (Value) -> Void) -> MultiPromise<Value> {
        let worker = DispatchQueue.main
        addCallback(for: worker, onFulfilled: onFulfilled, onRejected: { _ in })

        return self
    }

    // MARK: - Properties

    public var isPending: Bool {
        return currentState.isPending
    }

    public var isFulfilled: Bool {
        return currentState.isFulfilled
    }

    public var isRejected: Bool {
        return currentState.isRejected
    }

    public var value: Value? {
        return lockQueue.sync { state.value }
    }

    public var error: Error? {
        return lockQueue.sync { state.error }
    }

    private var currentState: State<Value> {
        return lockQueue.sync { state }
    }

    // MARK: - Helpers

    private func updateState(_ newState: State<Value>) {
        lockQueue.sync {
            state = newState
        }
        tryExecCallbacks()
    }

    private func addCallback(for worker: ExecutionContext, onFulfilled: @escaping (Value) -> Void, onRejected: @escaping (Error) -> Void) {
        defer {
            tryExecCallbacks()
        }

        let callback = Callback<Value>(onFulfilled: onFulfilled, onRejected: onRejected, worker: worker)
        lockQueue.async {
            self.callbacks.append(callback)
        }
    }

    private func tryExecCallbacks() {
        lockQueue.async {
            guard !self.state.isPending else { return }
            self.execCallbacks(for: self.state)
        }
    }

    private func execCallbacks(for state: State<Value>) {
        switch state {
        case let .fulfilled(value):
            callbacks.forEach { $0.callFulfill(value) }
        case let .rejected(error):
            callbacks.forEach { $0.callReject(error) }
        default:
            break
        }
    }

    // MARK: - Init

    public init() {
        state = .pending
    }

    public init(value: Value) {
        state = .fulfilled(value)
    }

    public init(error: Error) {
        state = .rejected(error)
    }

    public convenience init(queue: DispatchQueue, work: @escaping PromiseWorkBlock<Value>) {
        self.init()
        queue.async {
            do {
                try work(self.fulfill, self.reject)
            } catch {
                self.reject(error)
            }
        }
    }
}
