//
//  RealMovieDBMoviesRepository.swift
//  
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import Foundation
import UIKit

struct RealMovieDBMoviesRepository: MovieDBMoviesRepository {
    func fetchMovies() -> AnyPublisher<Movies.GetMovies.Response.Body, Error> {
        RequestBuilderFactory
         .create(Movies.GetMovies.self)
         .request(.init())
         .headers(.init(authorisation: "Authorization: Bearer \(Constants.apiKey)" ))
         .queryItems(.init(page: 1, language: "pl"))
         .perform(with: URLSession.shared)
         .map { $0.data }
         .eraseToAnyPublisher()
    }
    
    public init() {}
}

private enum Constants {
    static let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlOTdiMGQ0YWQ3MzZjZWI2NzEyYjk4MzNiYmFjMDQ3MCIsInN1YiI6IjVhMWZkMjAxYzNhMzY4MGI4ODA4Yzg0MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.YiTcXE0dy8qu6E_7JsrhbEhSXPcqmP-PftTD7wl5lMk"
}
