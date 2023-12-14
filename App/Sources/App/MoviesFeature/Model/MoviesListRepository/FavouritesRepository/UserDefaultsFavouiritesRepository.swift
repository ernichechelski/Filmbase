//
//  UserDefaultsFavouiritesRepository.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine
import Foundation

struct UserDefaultsFavouiritesRepository: FavouiritesRepository {
  private var model: AnyPublisher<FavouriteMoviesIDs, Never> {
    modelSubject.share().compactMap { $0 }.eraseToAnyPublisher()
  }

  private var modelSubject = CurrentValueSubject<FavouriteMoviesIDs?, Never>(.none)

  func fetchIDs() -> AnyPublisher<[Int], Error> {
    read()
      .map {
        self.modelSubject.send($0)
      }
      .flatMap { _ in
        self.fetchFromCache()
      }
      .eraseToAnyPublisher()
      .map(\.ids).eraseToAnyPublisher()
  }

  func save(favouiriteID: Int) -> AnyPublisher<Void, Error> {
    read()
      .map { ids in
        var ids = ids
        if !ids.ids.contains(favouiriteID) {
          ids.ids.append(favouiriteID)
        }
        return ids
      }
      .flatMap(save)
      .eraseToAnyPublisher()
  }

  func remove(favouiriteID: Int) -> AnyPublisher<Void, Error> {
    read()
      .map { ids in
        var ids = ids
        if let index = ids.ids.firstIndex(of: favouiriteID) {
          ids.ids.remove(at: index)
        }
        return ids
      }
      .flatMap(save)
      .eraseToAnyPublisher()
  }
  
  private func fetchFromCache() -> AnyPublisher<FavouriteMoviesIDs, Error> {
    model
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }

  private func save(ids: FavouriteMoviesIDs) -> AnyPublisher<Void, Error> {
    Result {
      try UserDefaults.standard.setValue(ids.asJSON(), forKey: Constants.userDefaultsKey)
      self.modelSubject.send(ids)
    }
    .publisher
    .eraseToAnyPublisher()
  }

  private func read() -> AnyPublisher<FavouriteMoviesIDs, Error> {
    Result {
      try FavouriteMoviesIDs.from(
        jsonString: UserDefaults.standard.string(
          forKey: Constants.userDefaultsKey
        ) ?? ""
      )
    }
    .publisher
    .replaceError(with: FavouriteMoviesIDs(ids: []))
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()
  }
  
  private enum Constants {
    static let userDefaultsKey = "FavouriteMoviesIDs"
  }
  
  private struct FavouriteMoviesIDs: Codable {
    var ids: [Int]
  }
}
