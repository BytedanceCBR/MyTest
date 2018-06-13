//
//  Functional.swift
//  Lark
//
//  Created by linlin on 2017/3/14.
//  Copyright © 2017年 Bytedance.Inc. All rights reserved.
//

import Foundation

public func memoize<T: Hashable, U>(body: @escaping (T) -> U) -> (T) -> U {
    var memo: [T: U] = [:]
    return { x in
        if let q = memo[x] { return q }
        let r = body(x)
        memo[x] = r
        return r
    }
}

public typealias VoidCallback = () -> Void
public func once(callback:@escaping VoidCallback, overExcuted: (() -> Void)? = nil) -> VoidCallback {
    var excuted = false
    return {
        if !excuted {
            callback()
            excuted = true
        } else {
            overExcuted?()
        }
    }
}

public func fetchObjProperties(obj: Any) -> [(label: String?, value: Any)] {
    let properties = Mirror(reflecting: obj)
        .children
        .reduce([]) { (result, value) -> [(label: String?, value: Any)] in
            return result + [(value.label?.replacingOccurrences(of: ".storage", with: ""), value.value)]
        }
    return properties
}

public func caseConvert<S, T>(source: S) -> T? {
    guard let target: T = source as? T else {
        return nil
    }

    return target
}

public func convertNSDict2Dict(source: NSDictionary) -> [AnyHashable: Any]? {
    return caseConvert(source: source)
}

public func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

extension Array {
    public var decompose : (head: Element, tail: [Element])? {
        return isEmpty ? (self[0], Array(self[1..<count])) : nil
    }
}

/// The Box class is used to box values and as a workaround to the limitations
/// with generics in the compiler.
public class Boxa<T> {
    public let unbox: T
    public init(_ value: T) { self.unbox = value }
}
