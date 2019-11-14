//
//  Array+extension.swift
//  MonarchRouter
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import Foundation



extension Array
{
    /// Returns the first non-nil result passed through the predicate.
    /// - parameter predicate: Closure that accepts an element and returns an optional value.
    /// - returns: The first non-nil value returned by the predicate, else nil.
    func firstResult<T>(_ predicate: (Element) -> T?) -> T? {
        for item in self {
            if let result = predicate(item) {
                return result
            }
        }
        return nil
    }
}


extension Set
{
    mutating func remove(matching: (_ element: Element) -> Bool)
    {
        var set = self
        let removeElements = set.filter { matching($0) }
        removeElements.forEach { set.remove($0) }
        self = set
    }
}


extension Collection
{
    func mapToDictionary<K, V>(_ map: ((Self.Iterator.Element) -> (K, V)?))  -> [K: V]
    {
        var d = [K: V]()
        for e in self {
            if let kV = map(e) {
                d[kV.0] = kV.1
            }
        }
        
        return d
    }
}
