//
//  File.swift
//  
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Foundation
import Combine

final class MoviesPresenter {
    
    var model: AnyPublisher<MoviesListModel, Never> {
        modelSubject.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let moviesRepository: MoviesListRepository = RealMoviesListRepository()
    
    private var modelSubject = CurrentValueSubject<MoviesListModel?, Never>(.none)
    
    func load() {
        self.modelSubject.send(.init(isLoading: true, movies: modelSubject.value?.movies ?? [], onEvent: { _ in }))
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
        moviesRepository.markAsFavourite(movie: movie)
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
    
    func unmarkAsFavourite(movie: Movie) {
        moviesRepository.unmarkAsFavourite(movie: movie)
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
}
