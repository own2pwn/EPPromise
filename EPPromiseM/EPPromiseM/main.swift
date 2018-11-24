//
//  main.swift
//  EPPromiseM
//
//  Created by Evgeniy on 24/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public typealias ValueBlock<Value> = (Value) -> Void

public typealias ErrorBlock = (Error) -> Void

public typealias VoidBlock = () -> Void

public protocol IPromise: class {
    associatedtype Value

    func fulfill(_ value: Value)
    func reject(_ error: Error)

    /// FlatMap
    @discardableResult
    func then<NewValue>(_ transform: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue>

    /// Map
    @discardableResult
    func then<NewValue>(_ transform: @escaping (Value) throws -> NewValue) -> Promise<NewValue>

    // MARK: - Passthrough

    /// Will be executed on Main Thread
    @discardableResult
    func finalize(_ onFulfilled: @escaping (Value) -> Void) -> Promise<Value>

    /// Will be executed on service queue
    @discardableResult
    func then(_ onFulfilled: @escaping (Value) -> Void) -> Promise<Value>

    @discardableResult
    func then(_ onFulfilled: @escaping (Value) -> Void, _ onRejected: @escaping (Error) -> Void) -> Promise<Value>

    /// For custom exec context
    @discardableResult
    func then(worker: ExecutionContext, _ onFulfilled: @escaping (Value) -> Void) -> Promise<Value>

    @discardableResult
    func then(worker: ExecutionContext, _ onFulfilled: @escaping (Value) -> Void, _ onRejected: @escaping (Error) -> Void) -> Promise<Value>

    // MARK: - Members

    var isPending: Bool { get }

    var isFulfilled: Bool { get }

    var isRejected: Bool { get }

    var value: Value? { get }

    var error: Error? { get }
}

final class PromiseTester {
    func testPromise() {
        let p = Promise<Int>()
        // p.fulfill(3)
        //
        testPromiseFulfill(p, with: 4)
        p.then(testThen).then(testThenTransform).then(testThenTypeTransform).finalize { value in
            print("param here: \(value)")
            print("got \(value) on main ?: \(Thread.isMainThread)")
        }
    }

    @discardableResult
    private func testPromiseFulfill<T>(_ promise: Promise<T>, with value: T) -> Promise<T> {
        sleep(2)
        promise.fulfill(value)

        return promise
    }

    private func testThen(_ param: Int) {
        print("testThen(param: \(param)) on main ?: \(Thread.isMainThread)")
        sleep(1)
    }

    private func testThenTransform(_ param: Int) -> Int {
        print("param [\(param)] => [\(param + 10)]")
        sleep(1)

        return param + 10
    }

    private func testThenTypeTransform(_ param: Int) -> String {
        print("got \(param) => mem")
        sleep(1)

        return "mem"
    }
}

let tester = PromiseTester()
tester.testPromise()

RunLoop.main.run()
