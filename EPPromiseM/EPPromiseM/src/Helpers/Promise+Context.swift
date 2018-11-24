//
//  Promise+Context.swift
//  EPPromiseM
//
//  Created by Evgeniy on 24/11/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Foundation

public protocol ExecutionContext {
    func execute(_ work: @escaping () -> Void)
}

extension DispatchQueue: ExecutionContext {
    public func execute(_ work: @escaping () -> Void) {
        async(execute: work)
    }
}
