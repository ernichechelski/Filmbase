//
//  MovieDetailsPresenter.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import UIKit

final class MovieDetailsPresenter {
  var model: AnyPublisher<MovieDetailsViewController.Model, Never> {
    modelSubject.compactMap { $0 }.eraseToAnyPublisher()
  }
  
  private var cancellables = Set<AnyCancellable>()
  private let movie: Movie
  private let modelSubject = CurrentValueSubject<MovieDetailsViewController.Model?, Never>(.none)
  private let moviesRepository: MoviesListRepository
  
  init(movie: Movie, moviesRepository: MoviesListRepository) {
    self.movie = movie
    self.moviesRepository = moviesRepository
  }
 
  func load() {
    modelSubject.send(
      .init(
        titleText: movie.title,
        releaseDateText: "\(movie.releseDate)",
        gradeText: "\(movie.grade)",
        descriptionText: movie.overview,
        isLoading: true,
        isFavourite: movie.isFavourite
      )
    )
    
    movie.image.uiImage.sink { completion in } receiveValue: { [weak self] in
      self?.updateImage(uiImage: $0)
    }.store(in: &cancellables)
  }
  
  func favouriteButtonTapped() {
    guard let model = modelSubject.value else {
      return
    }
    
    let expectedIsFavourite = !model.isFavourite
    // We are doing shortcut here,
    // as movie property stays unsychronised but in this case it is not an issue.
    
    let publisher = expectedIsFavourite ? moviesRepository.markAsFavourite(movie: movie) : moviesRepository.unmarkAsFavourite(movie: movie)
    
    publisher
      .sink(receiveCompletion: { _ in } , receiveValue: { [weak self] _ in
        guard let self = self else {
          return
        }
        
        self.modelSubject.update {
          $0?.isFavourite = expectedIsFavourite
        }
      })
      .store(in: &cancellables)
  }
  
  private func updateImage(uiImage: UIImage) {
    modelSubject.update {
      $0?.image = uiImage
    }
  }
}
