//
//  RealMoviesListRepository.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import Foundation

final class RealMoviesListRepository: MoviesListRepository {
  private enum Failure: Error {
    case wrongDateFormat
  }
  
  private let modelSubject = CurrentValueSubject<Dictionary<Int, Movies.GetMovies.Response.Body>, Never>([:])
  private let moviesRepository: MovieDBMoviesRepository = RealMovieDBMoviesRepository()
  private let favouiritesRepository: FavouiritesRepository = UserDefaultsFavouiritesRepository()
  
  func fetchMovies(page: Int) -> AnyPublisher<[Movie], Error> {
    moviesRepository
      .fetchMovies(page: page)
      .map { response in
        self.modelSubject.update {
          $0[page] = response
        }
      }
      .flatMap { _ in
        self.fetchFromCache(page: page)
      }
      .eraseToAnyPublisher()
  }
  
  func fetchSearchSuggestions(text: String) -> AnyPublisher<[MovieSearchSuggestion], Error> {
    moviesRepository.fetchSearchSuggestions(text: text)
  }

  func markAsFavourite(movie: Movie) -> AnyPublisher<Void, Error> {
    favouiritesRepository.save(favouiriteID: movie.id)
  }

  func unmarkAsFavourite(movie: Movie) -> AnyPublisher<Void, Error> {
    favouiritesRepository.remove(favouiriteID: movie.id)
  }
  
  private func fetchFromCache(page: Int) -> AnyPublisher<[Movie], Error> {
    modelSubject.compactMap { $0[page] }.eraseToAnyPublisher()
      .setFailureType(to: Error.self)
      .combineLatest(favouiritesRepository.fetchIDs())
      .tryMap { movies, favouiritesIds in
        try movies.results.map {
          Movie(
            id: $0.id,
            title: $0.originalTitle,
            image: self.moviesRepository.fetchImage(path: $0.posterPath ?? $0.backdropPath ?? ""),
            releseDate: try Constants.moviesDBDateFormatter.date(
              from: $0.releaseDate
            ).throwing(error: Failure.wrongDateFormat),
            grade: Float($0.voteAverage),
            overview: $0.overview,
            isFavourite: favouiritesIds.contains($0.id)
          )
        }
      }
      .eraseToAnyPublisher()
  }
}

private enum Constants {
  static let moviesDBDateFormatter = with(DateFormatter()) {
    $0.dateFormat = "YYYY-mm-dd"
  }
}
