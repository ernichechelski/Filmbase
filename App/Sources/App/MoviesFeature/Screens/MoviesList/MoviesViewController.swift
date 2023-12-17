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
  
  private lazy var searchController = with(UISearchController(searchResultsController: nil)) {
    $0.searchResultsUpdater = self
    $0.obscuresBackgroundDuringPresentation = false
//    $0.hidesNavigationBarDuringPresentation = false
    $0.searchBar.delegate = self
    $0.searchBar.placeholder = "Enter the movie name"
  }
 

  private let presenter: MoviesPresenter

  init(presenter: MoviesPresenter) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    
  }

  override public func loadView() {
    super.loadView()
    navigationItem.title = "Movies"
    navigationItem.searchController = searchController
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
    presenter.model
      .replaceError(with: .init(movies: [], searchSuggestions: []))
      .sink { completion in
        print(completion)
      } receiveValue: { [weak self] model in
        self?.model = model
        self?.rootTableView.reloadData()
        if #available(iOS 16.0, *) {
          self?.searchController.searchSuggestions = model.searchSuggestions.map {
            UISearchSuggestionItem(localizedSuggestion: $0)
          }
        }
        
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

extension MoviesViewController: UISearchResultsUpdating {
  
  
  func updateSearchResults(for searchController: UISearchController) {
    presenter.updateQuery(text: searchController.searchBar.text)
  }
  
  @available(iOS 16.0, *)
  func updateSearchResults(for searchController: UISearchController, selecting searchSuggestion: UISearchSuggestion) {
    searchController.searchSuggestions?.removeAll()
    searchController.searchBar.text = searchSuggestion.localizedSuggestion
    searchController.dismiss(animated: true)
    presenter.updateQuery(text: searchSuggestion.localizedSuggestion)
  }
}

extension MoviesViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    model?.movies.count ?? 0
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "identifier") as? MovieCell
    if let movie = model?.movies[indexPath.row].value {
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
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard indexPath.row + 1 == model?.movies.count else {
      return
    }
    presenter.loadNextPage()
  }
}

extension MoviesViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let movie = model?.movies[indexPath.row] else {
      return
    }
    presenter.movieSelected(movie: movie.value)
  }
}

extension MoviesViewController: UISearchBarDelegate {
  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool  {
    searchController.dismiss(animated: true)
    presenter.updateQuery(text: searchBar.text)
    return true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchController.dismiss(animated: true)
  }
}

extension UIView {
  func layoutable() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
}
