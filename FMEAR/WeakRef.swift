//
//  WeakRef.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-08-24.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation

class WeakRef<T> where T: AnyObject {

    private(set) weak var value: T?

    init(value: T?) {
        self.value = value
    }
}
