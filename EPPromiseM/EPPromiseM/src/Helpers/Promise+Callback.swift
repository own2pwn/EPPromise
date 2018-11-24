//
//  Promise+Callback.swift
//  EPPromiseM
//
//  Created by Evgeniy on 24/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

struct Callback<Value> {
    let onFulfilled: (Value) -> Void
    let onRejected: (Error) -> Void
    let worker: ExecutionContext
}

extension Callback {
    // MARK: - Methods

    func callFulfill(_ value: Value) {
        worker.execute {
            self.onFulfilled(value)
        }
    }

    func callReject(_ error: Error) {
        worker.execute {
            self.onRejected(error)
        }
    }
}
