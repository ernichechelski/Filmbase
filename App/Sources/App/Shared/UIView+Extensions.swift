//
//  UIView+Extensions.swift
//
//
//  Created by Ernest Chechelski on 18/12/2023.
//

import UIKit

extension UIView {
  func layoutable() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
}
