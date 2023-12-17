//
//  MovieCell.swift
//
//
//  Created by Ernest Chechelski on 15/12/2023.
//

import UIKit

final class MovieCell: UITableViewCell {

  struct ComponentModel {
    enum Event {
      case onToggleFavouriteButton
      case checkMovieButtonTapped
    }
    var title: String
    var isFavourite: Bool
    var onEvent: (Event) -> Void
  }
  
  func fill(with model: ComponentModel) {
    self.model = model
    titleLabel.text = model.title
    toggleFavouriteButton.setTitle(model.isFavourite ? "Unmark" : "Mark", for: .normal)
  }
  
  private let rootStackView = with(UIStackView().layoutable()) {
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.alignment = .top
    $0.isLayoutMarginsRelativeArrangement = true
    $0.directionalLayoutMargins = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
  }
  
  private let leadingStackView = with(UIStackView().layoutable()) {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.alignment = .leading
  }
  
  private let titleLabel = with(UILabel()) {
    $0.numberOfLines = 10
    $0.font = .preferredFont(forTextStyle: .title3)
  }

  private let proceedButton = with(UIButton(type: .system)) {
    $0.setTitle("Check", for: .normal)
  }
  
  private let toggleFavouriteButton = with(UIButton(type: .system)) {
    $0.setTitle("", for: .normal)
  }
  
  private var model = ComponentModel(title: "", isFavourite: false) { _ in }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    fillView()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Methods [private]

  private func fillView() {
    contentView.addSubview(rootStackView)
    
    NSLayoutConstraint.activate([
      rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
    
    rootStackView.addArrangedSubview(leadingStackView)
    rootStackView.addArrangedSubview(proceedButton)
    leadingStackView.addArrangedSubview(titleLabel)
    leadingStackView.addArrangedSubview(toggleFavouriteButton)
    
    proceedButton.addTarget(self, action: #selector(proceedButtonTapped), for: .touchUpInside)
    toggleFavouriteButton.addTarget(self, action: #selector(toggleFavouriteButtonTapped), for: .touchUpInside)
  }
  
  
  @objc private func proceedButtonTapped(_ sender: AnyObject) {
    model.onEvent(.checkMovieButtonTapped)
  }
  
  @objc private func toggleFavouriteButtonTapped(_ sender: AnyObject) {
    model.onEvent(.onToggleFavouriteButton)
  }
}
