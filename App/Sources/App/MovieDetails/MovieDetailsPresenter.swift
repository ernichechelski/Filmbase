//
//  MovieDetailsPresenter.swift
//  
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import UIKit
import Combine

final class MovieDetailsPresenter {
    
    private var cancellables = Set<AnyCancellable>()
    
    var model: AnyPublisher<MovieDetailsViewController.Model, Never> {
        modelSubject.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    private var modelSubject = CurrentValueSubject<MovieDetailsViewController.Model?, Never>(.none)

    func load() {
        modelSubject.send(.init(titleText: "Title", releaseDateText: "Release", gradeText: "Grade", descriptionText: "Description"))
    }
    
    func markAsFavourite(movie: Movie) {
        
    }
    
    func unmarkAsFavourite(movie: Movie) {
        
    }
}

public class MovieDetailsViewController: UIViewController {
    
    struct Model {
        var titleText: String
        var releaseDateText: String
        var gradeText: String
        var descriptionText: String
    }
    
    var rootStackView = with(UIStackView().layoutable()) { _ in }
    
    private let presenter = MoviesPresenter()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    private let titleLabel = with(UILabel()) {
            $0.numberOfLines = 0
//            $0.set(typography: .typographyBodyBody2Normal)
    }
    
    
    private let releaseDateLabel = with(UILabel()) {
            $0.numberOfLines = 0
//            $0.set(typography: .typographyBodyBody2Normal)
    }
    
    private let gradeLabel = with(UILabel()) {
            $0.numberOfLines = 0
//            $0.set(typography: .typographyBodyBody2Normal)
    }
    
    private let descriptionLabel = with(UILabel()) {
            $0.numberOfLines = 0
//            $0.set(typography: .typographyBodyBody2Normal)
    }

    
    private var cancellables = Set<AnyCancellable>()
    
    private var model: MoviesListModel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        navigationItem.title = "Movies"
        
        view.addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.topAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        [
            titleLabel,
            releaseDateLabel,
            gradeLabel,
            descriptionLabel
        ]
            .forEach(rootStackView.addArrangedSubview)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        presenter.model.sink { completion in
            print(completion)
        } receiveValue: { [weak self] model in
            self?.model = model
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
}
