//
//  MovieDetailsPresenter.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import UIKit

final class MovieDetailsPresenter {
  private var cancellables = Set<AnyCancellable>()

  var model: AnyPublisher<MovieDetailsViewController.Model, Never> {
    modelSubject.compactMap { $0 }.eraseToAnyPublisher()
  }

  private var modelSubject = CurrentValueSubject<MovieDetailsViewController.Model?, Never>(.none)

  func load() {
    modelSubject.send(
      .init(
        titleText: "Title",
        releaseDateText: "Release",
        gradeText: "Grade",
        descriptionText: "Description"
      )
    )
  }

  func markAsFavourite(movie: Movie) {
    
  }

  func unmarkAsFavourite(movie: Movie) {
  }
}

class MovieDetailsViewController: UIViewController, ViewControllerRoutes {
  struct Model {
    var titleText: String
    var releaseDateText: String
    var gradeText: String
    var descriptionText: String
  }
  
  func fill(with model: Model) {
    titleLabel.text = model.titleText
    releaseDateLabel.text = model.releaseDateText
    gradeLabel.text = model.gradeText
    descriptionLabel.text = model.descriptionText
  }
  
  private var cancellables = Set<AnyCancellable>()

  private var model: MoviesListModel?

  private let rootStackView = with(UIStackView().layoutable()) {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.alignment = .leading
    $0.isLayoutMarginsRelativeArrangement = true
    $0.directionalLayoutMargins = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
  }

  private let titleLabel = with(UILabel()) {
    $0.numberOfLines = 10
    $0.font = .preferredFont(forTextStyle: .title1)
  }

  private let releaseDateLabel = with(UILabel()) {
    $0.numberOfLines = 10
    $0.font = .preferredFont(forTextStyle: .subheadline)
  }

  private let gradeLabel = with(UILabel()) {
    $0.numberOfLines = 10
    $0.font = .preferredFont(forTextStyle: .caption1)
  }

  private let descriptionLabel = with(UILabel()) {
    $0.numberOfLines = 10
    $0.font = .preferredFont(forTextStyle: .body)
  }

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func loadView() {
    super.loadView()
    navigationItem.title = "Movies"

    view.addSubview(rootStackView)
    NSLayoutConstraint.activate([
      rootStackView.topAnchor.constraint(equalTo: view.topAnchor),
      rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
    ])

    [
      titleLabel,
      releaseDateLabel,
      gradeLabel,
      descriptionLabel,
    ]
    .forEach(rootStackView.addArrangedSubview)
  }
}
