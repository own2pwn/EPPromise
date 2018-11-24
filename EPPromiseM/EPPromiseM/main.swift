//
//  main.swift
//  EPPromiseM
//
//  Created by Evgeniy on 24/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation
import MultiPromise
import Promise

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

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            print("started!")
            p.fulfill(77)
        }
    }

    func testMultiPromise() {
        let p = MultiPromise<Int>().finalize { v in
            let t = type(of: v)
            print("mp: \(v) | \(t)")
        }
        p.then { v in
            let t = type(of: v)
            print("mp[2]: \(v) | \(t)")
        }

        p.fulfill(2)
        p.fulfill(3)

        p.then { v in
            return "str: \(v)"
        }

        p.fulfill(44)
    }

    @discardableResult
    private func testPromiseFulfill<T>(_ promise: Promise<T>, with value: T) -> Promise<T> {
        sleep(2)
        promise.fulfill(value)

        return promise
    }

    @discardableResult
    private func testPromiseFulfill<T>(_ promise: MultiPromise<T>, with value: T) -> MultiPromise<T> {
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
tester.testMultiPromise()

RunLoop.main.run()
