//
//  main.swift
//  EPPromiseM
//
//  Created by Evgeniy on 24/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

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
