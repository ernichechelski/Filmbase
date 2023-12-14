//
//  MovieDBMoviesRepository.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine

protocol MovieDBMoviesRepository {
  func fetchMovies() -> AnyPublisher<Movies.GetMovies.Response.Body, Error>
}
