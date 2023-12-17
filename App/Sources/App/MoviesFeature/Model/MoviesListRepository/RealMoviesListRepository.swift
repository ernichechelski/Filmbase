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
  
  var model: AnyPublisher<Movies.GetMovies.Response.Body, Never> {
    modelSubject.share().compactMap { $0 }.eraseToAnyPublisher()
  }

  private let modelSubject = CurrentValueSubject<Movies.GetMovies.Response.Body?, Never>(.none)
  private let moviesRepository: MovieDBMoviesRepository = RealMovieDBMoviesRepository()
  private let favouiritesRepository: FavouiritesRepository = UserDefaultsFavouiritesRepository()
  
  func fetchMovies() -> AnyPublisher<[Movie], Error> {
    moviesRepository
      .fetchMovies()
      .map {
        self.modelSubject.send($0)
      }
      .flatMap { _ in
        self.fetchFromCache()
      }
      .eraseToAnyPublisher()
  }

  func markAsFavourite(movie: Movie) -> AnyPublisher<Void, Error> {
    favouiritesRepository.save(favouiriteID: movie.id)
  }

  func unmarkAsFavourite(movie: Movie) -> AnyPublisher<Void, Error> {
    favouiritesRepository.remove(favouiriteID: movie.id)
  }
  
  private func fetchFromCache() -> AnyPublisher<[Movie], Error> {
    model
      .setFailureType(to: Error.self)
      .combineLatest(favouiritesRepository.fetchIDs())
      .tryMap { movies, favouiritesIds in
        try movies.results.map {
          Movie(
            id: $0.id,
            title: $0.originalTitle,
            image: self.moviesRepository.fetchImage(path: $0.posterPath),
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
