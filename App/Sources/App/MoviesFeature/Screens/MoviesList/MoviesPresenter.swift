//
//  File.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import Foundation

final class MoviesPresenter {
 
  var onEvent: (MoviesListEvent) -> Void = { _ in }

  var model: AnyPublisher<MoviesListModel, Never> {
    modelSubject.compactMap { $0 }.eraseToAnyPublisher()
  }

  private var cancellables = Set<AnyCancellable>()
  private var modelSubject = CurrentValueSubject<MoviesListModel?, Never>(.none)
  
  init(moviesRepository: MoviesListRepository) {
    self.moviesRepository = moviesRepository
  }
  
  private let moviesRepository: MoviesListRepository

  func load(isPullToRefresh: Bool = false) {
    modelSubject.send(.init(isLoading: !isPullToRefresh, movies: modelSubject.value?.movies ?? [], onEvent: { _ in }))
    cancellables.removeAll()
    moviesRepository
      .fetchMovies()
      .receive(on: RunLoop.main)
      .sink { completion in
        print(completion)
      } receiveValue: { movies in
        print("Refreshed movies: \(movies)")
        self.modelSubject.send(.init(movies: movies, onEvent: { _ in }))
      }
      .store(in: &cancellables)
  }

  func markAsFavourite(movie: Movie) {
    moviesRepository
      .markAsFavourite(movie: movie)
      .sink(receiveCompletion: { _ in }, receiveValue: {})
      .store(in: &cancellables)
  }

  func unmarkAsFavourite(movie: Movie) {
    moviesRepository
      .unmarkAsFavourite(movie: movie)
      .sink(receiveCompletion: { _ in }, receiveValue: {})
      .store(in: &cancellables)
  }
  
  func movieSelected(movie: Movie) {
    onEvent(.requestedShowMovieDetails(movie))
  }
}
