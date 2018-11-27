//
//  Functional.swift
//  Lark
//
//  Created by linlin on 2017/3/14.
//  Copyright © 2017年 Bytedance.Inc. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)

    func state() -> Value? {
        switch self {
        case let .success(value):
            return value
        default:
            return nil
        }
    }
}

precedencegroup SequencePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

public func memoize<T: Hashable, U>(body: @escaping (T) -> U) -> (T) -> U {
    var memo: [T: U] = [:]
    return { x in
        if let q = memo[x] {
            return q
        }
        let r = body(x)
        memo[x] = r
        return r
    }
}

public typealias VoidCallback = () -> Void

public func once(callback: @escaping VoidCallback, overExcuted: (() -> Void)? = nil) -> VoidCallback {
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
        let next = withUnsafeBytes(of: &i) {
            $0.load(as: T.self)
        }
        if next.hashValue != i {
            return nil
        }
        i += 1
        return next
    }
}

func join(_ tokens: [String], withStr: String) -> String {
    guard let (head, tail) = tokens.slice.decomposed else {
        return tokens.first ?? ""
    }
    return tail.reduce(head) { (result, item) -> String in
        "\(result)&\(item)"
    }
}


extension Array {
    var slice: ArraySlice<Element> {
        return ArraySlice(self)
    }
}

extension ArraySlice {
    var decomposed: (Element, ArraySlice<Element>)? {
        return isEmpty ? nil : (self[startIndex], self.dropFirst())
    }
}

extension Array {
    public var decompose: (head: Element, tail: [Element])? {
        return isEmpty ? (self[0], Array(self[1..<count])) : nil
    }
}

/// The Box class is used to box values and as a workaround to the limitations
/// with generics in the compiler.
public class Boxa<T> {
    public let unbox: T

    public init(_ value: T) {
        self.unbox = value
    }
}

func groups<T>(items: [T], rowCount: Int) -> [[T]] {
    return items.reduce([[T]]()) { (result, node: T) -> [[T]] in
        var result = result
        if var row = result.last, row.count < rowCount {
            row.append(node)
            result.remove(at: result.count - 1)
            result.append(row)
        } else {
            result.append([node])
        }
        return result
    }
}

func valueWithDefault<K, T>(
        map: [K: T],
        key: K,
        defaultValue: T) -> T {
    if let result = map[key] {
        return result
    } else {
        return defaultValue
    }
}
