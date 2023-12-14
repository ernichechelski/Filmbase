//
//  AppCoordinator.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import UIKit

public final class AppCoordinator {
  
  private weak var navigationController: UINavigationController?
  private let screensFactory = ScreensFactory()
  
  public init() {}
  
  public func start(_ navigationController: UINavigationController) {
    self.navigationController = navigationController
    let moviesList = screensFactory.createMoviesList { [weak self] event in
      switch event {
      case .requestedShowMovieDetails(let movie):
        self?.showDetails(movie: movie)
      }
    }
    navigationController.setViewControllers([moviesList.viewController], animated: false)
  }
  
  func showDetails(movie: Movie) {
    let vc = screensFactory.createMovieDetails(movie: movie)
    navigationController?.pushViewController(vc.viewController, animated: true)
  }
}
