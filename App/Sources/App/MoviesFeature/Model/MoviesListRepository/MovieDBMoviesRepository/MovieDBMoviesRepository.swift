//
//  MovieDBMoviesRepository.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine

protocol MovieDBMoviesRepository {
  func fetchMovies(page: Int) -> AnyPublisher<Movies.GetMovies.Response.Body, Error>
  func fetchSearchSuggestions(text: String) -> AnyPublisher<[MovieSearchSuggestion], Error>
  func fetchImage(path: String) -> ImageResource
}
