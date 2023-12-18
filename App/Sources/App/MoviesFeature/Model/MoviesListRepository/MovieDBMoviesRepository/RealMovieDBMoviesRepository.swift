//
//  RealMovieDBMoviesRepository.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import ApiClient
import Combine
import Foundation
import UIKit

struct MovieDBMoviesImageResource: ImageResource {
  let uiImage: AnyPublisher<UIImage, Error>
}

struct RealMovieDBMoviesRepository: MovieDBMoviesRepository {
  private let dispatchQueue = DispatchQueue(label: "RealMovieDBMoviesRepository")
  
  func fetchImage(path: String) -> ImageResource {
    /// There is no authentication layer here, so just Data(contentsOf:) initialiser is sufficient here.
    MovieDBMoviesImageResource(
      uiImage:
      Just(path)
        .subscribe(on: dispatchQueue)
        .tryMap {
          try Data(
            contentsOf: URL(
              string: MoviesDBConstants.basePostersPath + $0
            )
            .throwing()
          )
        }
        .tryMap {
          try UIImage(data: $0)
            .throwing()
        }
        .eraseToAnyPublisher()
    )
  }
  
  func fetchSearchSuggestions(text: String) -> AnyPublisher<[MovieSearchSuggestion], Error> {
    RequestBuilderFactory
      .create(Movies.GetMovieSearchSuggestionsMovies.self)
      .request(.init())
      .headers(.init(authorisation: "Authorization: Bearer \(Constants.apiKey)"))
      .queryItems(.init(query: text, page: 1, language: "pl"))
      .perform(with: URLSession.shared)
      .map {
        $0.data.results.map {
          .init(text: $0.originalTitle)
        }
      }
      .eraseToAnyPublisher()
  }

  func fetchMovies(page: Int) -> AnyPublisher<Movies.GetMovies.Response.Body, Error> {
    RequestBuilderFactory
      .create(Movies.GetMovies.self)
      .request(.init())
      .headers(.init(authorisation: "Authorization: Bearer \(Constants.apiKey)"))
      .queryItems(.init(page: page, language: "pl"))
      .perform(with: URLSession.shared)
      .map { $0.data }
      .eraseToAnyPublisher()
  }

  public init() {}
}

private enum Constants {
  static let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlOTdiMGQ0YWQ3MzZjZWI2NzEyYjk4MzNiYmFjMDQ3MCIsInN1YiI6IjVhMWZkMjAxYzNhMzY4MGI4ODA4Yzg0MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.YiTcXE0dy8qu6E_7JsrhbEhSXPcqmP-PftTD7wl5lMk"
}
