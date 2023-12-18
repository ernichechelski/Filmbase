//
//  File.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Foundation

struct MoviesListModel {
  var isLoading = false
  var movies: Dictionary<Int,[Identifable<Movie>]>
  var searchSuggestions: [String]
}

struct Page<Value> {
  var index: Int
  var items: [Value]
}

struct Identifable<Value>: Hashable {
  static func == (lhs: Identifable<Value>, rhs: Identifable<Value>) -> Bool {
    lhs.uuid == rhs.uuid
  }
  
  var value: Value
  var uuid: UUID
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(uuid)
  }
}
