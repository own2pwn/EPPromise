//
//  Promise+State.swift
//  EPPromiseM
//
//  Created by Evgeniy on 24/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

enum State<Value> {
    /// Will be either fulfilled or rejected
    case pending

    /// Successfully fulfilled
    case fulfilled(Value)

    /// Rejected with an Error
    case rejected(Error)
}

extension State {
    // MARK: - State

    var isPending: Bool {
        if case .pending = self {
            return true
        }
        return false
    }

    var isFulfilled: Bool {
        if case .fulfilled = self {
            return true
        }
        return false
    }

    var isRejected: Bool {
        if case .rejected = self {
            return true
        }
        return false
    }

    // MARK: - Members

    var value: Value? {
        guard case let .fulfilled(value) = self else {
            return nil
        }
        return value
    }

    var error: Error? {
        guard case let .rejected(error) = self else {
            return nil
        }
        return error
    }
}
