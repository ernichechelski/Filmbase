//
//  RealMoviesListRepository.swift
//  
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Foundation
import Combine

final class RealMoviesListRepository: MoviesListRepository {
    
    
    
    
    var model: AnyPublisher<Movies.GetMovies.Response.Body, Never> {
        modelSubject.share().compactMap { $0 }.eraseToAnyPublisher()
    }

    private var modelSubject = CurrentValueSubject<Movies.GetMovies.Response.Body?, Never>(.none)
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
    
    func fetchFromCache() -> AnyPublisher<[Movie], Error> {
        model
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
            .combineLatest(favouiritesRepository.fetchIDs())
            .eraseToAnyPublisher()
            .tryMap { movies, favouiritesIds in
                try movies.results.map {
                    Movie(
                        id: $0.id,
                        title: $0.originalTitle,
                        image: .init(),
                        releseDate: try Constants.moviesDBDateFormatter.date(
                            from: $0.releaseDate
                        ).throwing(error: Failure.wrongDateFormat),
                        grade: 1,
                        overview: "",
                        isFavourite: favouiritesIds.contains($0.id)
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    func markAsFavourite(movie: Movie) -> AnyPublisher<Void, Error> {
        favouiritesRepository.save(favouiriteID: movie.id)
    }
    
    func unmarkAsFavourite(movie: Movie) -> AnyPublisher<Void, Error> {
        favouiritesRepository.remove(favouiriteID: movie.id)
    }
    
    enum Failure: Error {
        case wrongDateFormat
    }
    
    
    enum Constants {
        static let moviesDBDateFormat = "2023-10-18"
        static let moviesDBDateFormatter = with(DateFormatter()) {
            $0.dateFormat = "YYYY-mm-dd"
        }
    }
}
