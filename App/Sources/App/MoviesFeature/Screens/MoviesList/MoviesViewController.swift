//
//  File.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import UIKit

final class MoviesViewController: UIViewController, ViewControllerRoutes {
  private var cancellables = Set<AnyCancellable>()
  private var model: MoviesListModel?

  private let refreshControl = UIRefreshControl()
  private let activityIndicatorView = with(UIActivityIndicatorView().layoutable()) {
    $0.hidesWhenStopped = true
  }

  private let rootTableView = with(UITableView().layoutable()) {
    $0.rowHeight = UITableView.automaticDimension
  }

  private let presenter: MoviesPresenter

  init(presenter: MoviesPresenter) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func loadView() {
    super.loadView()
    navigationItem.title = "Movies"

    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    rootTableView.dataSource = self
    rootTableView.delegate = self
    rootTableView.register(MovieCell.self, forCellReuseIdentifier: "identifier")

    view.addSubview(rootTableView)
    view.addSubview(activityIndicatorView)

    rootTableView.addSubview(refreshControl)

    NSLayoutConstraint.activate([
      rootTableView.topAnchor.constraint(equalTo: view.topAnchor),
      rootTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      rootTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      rootTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    NSLayoutConstraint.activate([
      activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  override public func viewWillAppear(_ animated: Bool) {
    cancellables.removeAll()
    presenter.model.sink { completion in
      print(completion)
    } receiveValue: { [weak self] model in
      self?.model = model
      self?.rootTableView.reloadData()
      if model.isLoading {
        self?.activityIndicatorView.startAnimating()
      } else {
        self?.refreshControl.endRefreshing()
        self?.activityIndicatorView.stopAnimating()
      }
    }
    .store(in: &cancellables)
    loadContent()
  }

  override public func viewDidDisappear(_ animated: Bool) {
    cancellables.removeAll()
  }

  @objc private func refresh(_ sender: AnyObject) {
    presenter.load(isPullToRefresh: true)
  }

  private func loadContent() {
    presenter.load()
  }
}

extension MoviesViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    model?.movies.count ?? 0
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier") as? MovieCell
    if let movie = model?.movies[indexPath.row] {
      cell?.fill(
        with: .init(
          title: movie.title,
          isFavourite: movie.isFavourite,
          onEvent: { [weak self] event in
            switch event {
            case .onToggleFavouriteButton:
              if movie.isFavourite {
                self?.presenter.unmarkAsFavourite(movie: movie)
              } else {
                self?.presenter.markAsFavourite(movie: movie)
              }
            case .checkMovieButtonTapped:
              self?.presenter.movieSelected(movie: movie)
            }
          }
        )
      )
    }
    return cell!
  }
}

extension MoviesViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let movie = model?.movies[indexPath.row] else {
      return
    }
    presenter.movieSelected(movie: movie)
  }
}

extension UIView {
  func layoutable() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
}
