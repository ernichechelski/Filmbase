//
//  MoviesListRepository.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine


protocol MoviesListRepository {
  func fetchSearchSuggestions(text: String) -> AnyPublisher<[MovieSearchSuggestion], Error>
  func fetchMovies(page: Int) -> AnyPublisher<[Movie], Error>
  func markAsFavourite(movie: Movie) -> AnyPublisher<Void, Error>
  func unmarkAsFavourite(movie: Movie) -> AnyPublisher<Void, Error>
}
