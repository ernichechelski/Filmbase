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
    modelSubject
      .compactMap { $0 }
      .combineLatest(querySubject)
      .map { model, query in
        let movies = query.isEmpty ? model.movies : model.movies.filter { movie in
          movie.value.title.uppercased().contains(query.uppercased())
        }

        return .init(
          isLoading: model.isLoading, movies: movies,
          searchSuggestions: model.searchSuggestions
        )
      }
      .eraseToAnyPublisher()
  }

  private var page = 1
  private var cancellables = Set<AnyCancellable>()
  private let modelSubject = CurrentValueSubject<MoviesListModel?, Never>(.none)
  private let querySubject = CurrentValueSubject<String, Never>("")
  private let loadNextPageSubject = PassthroughSubject<Void, Never>()
  private let searchSuggestionsSubject = CurrentValueSubject<[String], Never>([])
  private let moviesRepository: MoviesListRepository

  init(moviesRepository: MoviesListRepository) {
    self.moviesRepository = moviesRepository
    setup()
  }

  func load(isPullToRefresh: Bool = false) {
    modelSubject.update {
      $0?.isLoading = !isPullToRefresh
    }
    moviesRepository
      .fetchMovies(page: 1)
      .receive(on: RunLoop.main)
      .handleEvents(
        receiveSubscription: { [weak self] _ in
          self?.startLoading()
        },
        receiveCompletion: { [weak self] _ in
          self?.stopLoading()
        }
      )
      .sink { completion in
        print(completion)
      } receiveValue: { [weak self] movies in
        self?.modelSubject.send(
          .init(
            movies: movies.uniqued,
            searchSuggestions: []
          )
        )
      }
      .store(in: &cancellables)
  }

  func loadNextPage() {
    loadNextPageSubject.send(())
  }

  func fetchNextPage() {
    page += 1
    moviesRepository
      .fetchMovies(page: page)
      .receive(on: RunLoop.main)
      .sink { completion in
        print(completion)
      } receiveValue: { [weak self] movies in
        self?.append(movies: movies)
      }
      .store(in: &cancellables)
  }

  func append(movies: [Movie]) {
    modelSubject.update {
      $0?.movies.append(contentsOf: movies.uniqued)
    }
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
      .filter { text in
        text.count > 2
      }
      .removeDuplicates()
      .throttle(for: 2.0, scheduler: RunLoop.main, latest: true)
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
    guard !query.isEmpty else{
      modelSubject.update {
        $0?.searchSuggestions.removeAll()
      }
      return
    }
    moviesRepository
      .fetchSearchSuggestions(text: query)
      .replaceError(with: [])
      .receive(on: RunLoop.main)
      .handleEvents(
        receiveSubscription: { [weak self] _ in
          self?.startLoading()
        },
        receiveCompletion: { [weak self] _ in
          self?.stopLoading()
        }
      )
      .sink(receiveValue: { [weak self] suggestions in
        self?.modelSubject.update {
          $0?.searchSuggestions = suggestions.map(\.text)
        }
      })
      .store(in: &cancellables)
  }

  private func startLoading() {
    modelSubject.update {
      $0?.isLoading = true
    }
  }

  private func stopLoading() {
    modelSubject.update {
      $0?.isLoading = false
    }
  }
}

extension Collection {
  var uniqued: [Identifable<Element>] {
    map { .init(value: $0, uuid: UUID()) }
  }
}
