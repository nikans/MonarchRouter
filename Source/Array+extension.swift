//
//  Array+extension.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 16/11/2018.
//  Copyright © 2018 AtlasBiomed. All rights reserved.
//

import Foundation

extension Array {
    
    /**
     Returns the first non-nil result passed through the predicate.
     - parameter predicate: Closure that accepts an element and returns an optional value.
     - returns: The first non-nil value returned by the predicate, else nil.
     */
    func firstResult<T>(_ predicate: (Element) -> T?) -> T? {
        for item in self {
            if let result = predicate(item) {
                return result
            }
        }
        return nil
    }
}
