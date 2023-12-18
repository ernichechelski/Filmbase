//
//  MoviesPresenter.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import Foundation

final class MoviesPresenter {
  var onEvent: (MoviesListEvent) -> Void = { _ in }

  
  var isLoading: AnyPublisher<Bool, Never> {
    isLoadingSubject.eraseToAnyPublisher()
  }
  
  var searchSuggestions: AnyPublisher<[String], Never> {
    searchSuggestionsSubject
      .combineLatest(model, querySubject)
      .map { suggestions, model, query in
        if query.isEmpty {
          return []
        }
        return Array(Set(suggestions.filter { suggestion in
          let allMovies = Array(model.values).flatMap { $0 }
          return allMovies.contains(where: { movie in
            movie.value.title.contains(suggestion)
          })
        }))
      }
      .eraseToAnyPublisher()
  }
  
  var model: AnyPublisher<Dictionary<Int,[Identifable<Movie>]>, Never> {
    modelSubject
      .combineLatest(querySubject)
      .map { model, query in
        guard query.count > 2 else {
          return model
        }
        return model.mapValues { movies in
          movies.filter { movie in
            movie.value.title.uppercased().contains(query.uppercased())
          }
        }
      }
      .eraseToAnyPublisher()
  }

  private var page = 1
  private var cancellables = Set<AnyCancellable>()
  private let modelSubject = CurrentValueSubject<Dictionary<Int,[Identifable<Movie>]>, Never>([:])
  private let querySubject = CurrentValueSubject<String, Never>("")
  private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
  private let loadNextPageSubject = PassthroughSubject<Void, Never>()
  private let searchSuggestionsSubject = CurrentValueSubject<[String], Never>([])
  private let moviesRepository: MoviesListRepository

  init(moviesRepository: MoviesListRepository) {
    self.moviesRepository = moviesRepository
    setup()
  }

  func load(isPullToRefresh: Bool = false) {
    startLoading()
    moviesRepository
      .fetchMovies(page: 1)
      .receive(on: RunLoop.main)
      .sink { completion in
        print(completion)
      } receiveValue: { [weak self, page] movies in
        self?.append(movies: movies, page: page)
        self?.stopLoading()
      }
      .store(in: &cancellables)
  }

  func loadNextPage() {
    loadNextPageSubject.send(())
  }

  func markAsFavourite(movie: Movie) {
    moviesRepository
      .markAsFavourite(movie: movie)
      .replaceError(with: ())
      .sink(receiveValue: {})
      .store(in: &cancellables)
  }

  func unmarkAsFavourite(movie: Movie) {
    moviesRepository
      .unmarkAsFavourite(movie: movie)
      .replaceError(with: ())
      .sink(receiveValue: {})
      .store(in: &cancellables)
  }

  func updateQuery(text: String?) {
    querySubject.send(text ?? "")
  }

  func movieSelected(movie: Movie) {
    onEvent(.requestedShowMovieDetails(movie))
  }

  private func setup() {
    querySubject
      .removeDuplicates()
      .sink { [weak self] query in
        self?.fetchSuggestions(query: query)
      }
      .store(in: &cancellables)

    loadNextPageSubject
      .throttle(for: 4.0, scheduler: RunLoop.main, latest: false)
      .sink { [weak self] in
        self?.fetchNextPage()
      }
      .store(in: &cancellables)
  }

  private func fetchSuggestions(query: String) {
    guard query.count > 2 else{
      return
    }
    
    startLoading()
    moviesRepository
      .fetchSearchSuggestions(text: query)
      .replaceError(with: [])
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] suggestions in
        self?.searchSuggestionsSubject.send(suggestions.map { $0.text })
        self?.stopLoading()
      })
      .store(in: &cancellables)
  }

  private func fetchNextPage() {
    page += 1
    startLoading()
    moviesRepository
      .fetchMovies(page: page)
      .receive(on: RunLoop.main)
      .sink { completion in
        print(completion)
      } receiveValue: { [weak self, page] movies in
        self?.append(movies: movies, page: page)
        self?.stopLoading()
      }
      .store(in: &cancellables)
  }

  private func append(movies: [Movie], page: Int) {
    modelSubject.update {
      $0[page] = movies.uniqued
    }
  }

  private func startLoading() {
    isLoadingSubject.send(true)
  }

  private func stopLoading() {
    isLoadingSubject.send(false)
  }
}

private extension Collection {
  var uniqued: [Identifable<Element>] {
    map { .init(value: $0, uuid: UUID()) }
  }
}
