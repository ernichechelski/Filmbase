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

@inline(__always) func mutate<T>(_ target: T, block: (inout T) -> Void) -> T {
  var target = target
  block(&target)
  return target
}
