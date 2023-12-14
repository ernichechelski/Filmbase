//
//  File.swift
//  
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import UIKit
import Combine

public class MoviesViewController: UIViewController {
    
    let refreshControl = UIRefreshControl()
    let activityIndicatorView = with(UIActivityIndicatorView().layoutable()) {
        $0.hidesWhenStopped = true
    }
    
    let rootTableView = with(UITableView().layoutable()) { _ in
//        $0.tableFooterView = with(UIView()) { $0.backgroundColor = .systemBackground }
//        $0.rowHeight = UITableView.automaticDimension
//        $0.separatorColor = .clear
//        $0.allowsSelection = true
//        $0.backgroundColor = .app(.background)
//        $0.backgroundView?.backgroundColor = .app(.background)
    }
    
    private let presenter = MoviesPresenter()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private var model: MoviesListModel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        navigationItem.title = "Movies"
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        rootTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        
        view.addSubview(rootTableView)
        view.addSubview(activityIndicatorView)
        
        rootTableView.dataSource = self
        rootTableView.delegate = self
        rootTableView.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        NSLayoutConstraint.activate([
            rootTableView.topAnchor.constraint(equalTo: view.topAnchor),
            rootTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    public override func viewWillAppear(_ animated: Bool) {
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
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        cancellables.removeAll()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.load()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        presenter.load()
    }
}


extension MoviesViewController: UITableViewDataSource {
    
   
    public func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model?.movies.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier")
        if let movie = model?.movies[indexPath.row] {
            cell?.textLabel?.text = movie.title
            cell?.accessoryType = .disclosureIndicator
            if movie.isFavourite {
                cell?.textLabel?.textColor = .red
            } else {
                cell?.textLabel?.textColor = .black
            }
        }
        return cell!
    }
}

extension MoviesViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let movie = model?.movies[indexPath.row] else {
            return
        }
        if movie.isFavourite {
            presenter.unmarkAsFavourite(movie: movie)
        } else {
            presenter.markAsFavourite(movie: movie)
        }
    }
}


extension UIView {
    
    func layoutable() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
