//
//  Promise+InvalidatableQueue.swift
//  EPPromiseM
//
//  Created by Evgeniy on 24/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public final class EPInvalidatableQueue: ExecutionContext {
    // MARK: - Members

    private var valid = true

    private let queue: DispatchQueue

    // MARK: - Interface

    public func invalidate() {
        valid = false
    }

    public func execute(_ work: @escaping () -> Void) {
        guard valid else { return }
        queue.async(execute: work)
    }

    // MARK: - Init

    public init(queue: DispatchQueue) {
        self.queue = queue
    }
}
