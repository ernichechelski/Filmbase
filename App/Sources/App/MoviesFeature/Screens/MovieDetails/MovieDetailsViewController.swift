//
//  File.swift
//  
//
//  Created by Ernest Chechelski on 15/12/2023.
//

import UIKit
import Combine

final class MovieDetailsViewController: UIViewController, ViewControllerRoutes {
  struct Model {
    var titleText: String
    var releaseDateText: String
    var gradeText: String
    var descriptionText: String
    var isLoading: Bool
    var isFavourite: Bool
    var image: UIImage?
  }
  
  func fill(with model: Model) {
    titleLabel.text = model.titleText
    releaseDateLabel.text = model.releaseDateText
    gradeLabel.text = model.gradeText
    descriptionLabel.text = model.descriptionText
    posterImageView.image = model.image
    
    navigationItem.rightBarButtonItem = .init(
      image: model.isFavourite ? .init(systemName: "cross") : .init(systemName: "star"),
      style: .done,
      target: self,
      action: #selector(rightNavigationButtonTapped)
    )
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  private let rootScrollView = with(UIScrollView().layoutable()) {
    $0.backgroundColor = .systemBackground
  }

  private let rootStackView = with(UIStackView().layoutable()) {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.alignment = .leading
    $0.spacing = 10
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
  
  private let posterImageView = with(UIImageView()) {
    $0.contentMode = .scaleAspectFit
  }
  
  private let presenter: MovieDetailsPresenter
  
  init(presenter: MovieDetailsPresenter) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    cancellables.removeAll()
    presenter
      .model
      .receive(on: RunLoop.main)
      .sink { _ in } receiveValue: { [weak self] model in
        self?.fill(with: model)
      }
      .store(in: &cancellables)
    presenter.load()
  }
  
  override public func viewDidDisappear(_ animated: Bool) {
    cancellables.removeAll()
  }

  override public func loadView() {
    super.loadView()
    navigationItem.title = "Movie details"
    view.backgroundColor = .systemBackground
    view.addSubview(rootScrollView)
    rootScrollView.addSubview(rootStackView)
    [
      posterImageView,
      titleLabel,
      releaseDateLabel,
      gradeLabel,
      descriptionLabel,
    ]
    .forEach(rootStackView.addArrangedSubview)
    
    NSLayoutConstraint.activate([
      rootScrollView.topAnchor.constraint(equalTo: view.topAnchor),
      rootScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      rootScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      rootScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    
    NSLayoutConstraint.activate([
      rootStackView.topAnchor.constraint(equalTo: rootScrollView.topAnchor),
      rootStackView.leadingAnchor.constraint(equalTo: rootScrollView.leadingAnchor),
      rootStackView.trailingAnchor.constraint(equalTo: rootScrollView.trailingAnchor),
      rootStackView.bottomAnchor.constraint(equalTo: rootScrollView.bottomAnchor),
      rootStackView.widthAnchor.constraint(equalTo: rootScrollView.widthAnchor)
    ])
    
    NSLayoutConstraint.activate([
      posterImageView.widthAnchor.constraint(equalTo: rootStackView.widthAnchor),
      posterImageView.heightAnchor.constraint(equalToConstant: 200)
    ])
  }
  
  @objc private func rightNavigationButtonTapped(_ sender: AnyObject) {
    presenter.favouriteButtonTapped()
  }
}
