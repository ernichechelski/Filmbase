//
//  File.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Foundation

struct MoviesListModel {
  enum Event {
    case onMovieTappedAsFavouirite(Movie)
    case onMovieTappedAsUnFavouirite(Movie)
  }

  var isLoading = false
  var movies: [Movie]
  var onEvent: (Event) -> Void?
}
