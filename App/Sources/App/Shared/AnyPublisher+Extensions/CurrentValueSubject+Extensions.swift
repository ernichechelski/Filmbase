//
//  CurrentValueSubject+Extensions.swift
//
//
//  Created by Ernest Chechelski on 15/12/2023.
//

import Combine

extension CurrentValueSubject {
  /// By setting this value you can easily trigger also send event.
  var updatingValue: Output {
    get {
      value
    }
    set {
      send(newValue)
    }
  }
  
  /// Easy modification of current value by modifing it in provided closure as parameter.
  func update(_ closure: (inout Output) -> Void) {
    updatingValue = mutate(value, block: closure)
  }
}
