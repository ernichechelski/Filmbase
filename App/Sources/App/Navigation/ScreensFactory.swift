//
//  ScreensFactory.swift
//  
//
//  Created by Ernest Chechelski on 14/12/2023.
//

enum MoviesListEvent {
    case requestedShowMovieDetails(Movie)
}

final class ScreensFactory {
  
  private let moviesRepository: MoviesListRepository = RealMoviesListRepository()
  
  func createMoviesList(onEvent: @escaping (MoviesListEvent) -> Void) -> ViewControllerRoutes {
    let presenter = MoviesPresenter.init(moviesRepository: moviesRepository)
    let vc = MoviesViewController(presenter: presenter)
    presenter.onEvent = onEvent
    return vc
  }
  
  func createMovieDetails(movie: Movie) -> ViewControllerRoutes {
    let presenter = MovieDetailsPresenter(movie: movie, moviesRepository: moviesRepository)
    let vc = MovieDetailsViewController(presenter: presenter)
    return vc
  }
}
