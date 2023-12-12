//
//  Scope.swift
//  IOS_BASE
//

import Foundation

/// Creates value and runs given block on it, then returns it.
/// Useful when creating new variables with configuration, to avoid
/// introducing temporary variables.
///
/// - Parameters:
///   - target: Target object
///   - block: Method to be run on target object
@inline(__always) func with<T>(_ target: T, block: (T) -> Void) -> T {
    block(target)
    return target
}

@inline(__always) func with<T>(_ target: T, block: () -> Void) -> T {
    block()
    return target
}

@inline(__always) func guaranteeMainThread(_ work: @escaping () -> Void) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async { work() }
    }
}

@inline(__always) func asyncMainAfter(_ timeInterval: TimeInterval, _ work: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
        work()
    }
}

func fatalAppError(_ error: @autoclosure () -> Error = PackageError.development(), file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Error not handled anywhere! \(error().localizedDescription)")
}
