//
//  RealMoviesListRepository.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import Foundation
import UIKit

final class RealMoviesListRepository: MoviesListRepository {
  private enum Failure: Error {
    case wrongDateFormat
  }
  
  private let modelSubject = CurrentValueSubject<Dictionary<Int, Movies.GetMovies.Response.Body>, Never>([:])
  private let moviesRepository: MovieDBMoviesRepository
  private let favouiritesRepository: FavouiritesRepository
  
  init(
    moviesRepository: MovieDBMoviesRepository,
    favouiritesRepository: FavouiritesRepository
  ) {
    self.moviesRepository = moviesRepository
    self.favouiritesRepository = favouiritesRepository
  }
  
  func fetchMovies(page: Int) -> AnyPublisher<[Movie], Error> {
    moviesRepository
      .fetchMovies(page: page)
      .map { [weak self] response in
        guard let self else {
          return
        }
        self.modelSubject.update {
          $0[page] = response
        }
      }
      .flatMap { [weak self, page] _ in
        guard let self else {
          return Fail<[Movie], RealMoviesListRepository.Failure>(
            error: Failure.wrongDateFormat
          )
          .mapError { $0 as Error }
          .eraseToAnyPublisher()
        }
        return self.fetchFromCache(page: page)
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
      .tryMap { [weak self] movies, favouiritesIds in
        guard let self else {
          return []
        }
        return try movies.results.map {
          Movie(
            id: $0.id,
            title: $0.originalTitle,
            image: self.moviesRepository
              .fetchImage(
                path: $0.posterPath ?? $0.backdropPath ?? ""
              ) ,
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
