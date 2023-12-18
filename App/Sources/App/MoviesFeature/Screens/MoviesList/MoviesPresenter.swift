//
//  MoviesPresenter.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import Foundation

final class MoviesPresenter {
  
  /// All events triggered internaly but handled externally.
  var onEvent: (MoviesListEvent) -> Void = { _ in }

  /// Publisher indicates if the presenter loading something.
  var isLoading: AnyPublisher<Bool, Never> {
    isLoadingSubject.eraseToAnyPublisher()
  }
  
  /// Publisher with all useful search suggestions.
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
  
  /// Publisher with all movies splited into sections where key is section index.
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

  /// Loads initial data.
  func load() {
    page = 1
    startLoading()
    moviesRepository
      .fetchMovies(page: page)
      .replaceError(with: [])
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self, page] movies in
        self?.modelSubject.send([:])
        self?.append(movies: movies, page: page)
        self?.stopLoading()
      })
      .store(in: &cancellables)
  }

  /// Loads the next page of movies.
  func loadNextPage() {
    loadNextPageSubject.send(())
  }

  /// Marks the movie as favourite.
  func markAsFavourite(movie: Movie) {
    moviesRepository
      .markAsFavourite(movie: movie)
      .replaceError(with: ())
      .sink(receiveValue: {})
      .store(in: &cancellables)
  }

  /// Unmarks the movie as favourite.
  func unmarkAsFavourite(movie: Movie) {
    moviesRepository
      .unmarkAsFavourite(movie: movie)
      .replaceError(with: ())
      .sink(receiveValue: {})
      .store(in: &cancellables)
  }

  /// Updates search query which filters movies.
  func updateQuery(text: String?) {
    querySubject.send(text ?? "")
  }

  /// Triggered when the user selects movie.
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
