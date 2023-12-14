//
//  FavouiritesRepository.swift
//  
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import Combine


protocol FavouiritesRepository {
    func fetchIDs() -> AnyPublisher<[Int], Error>
    func save(favouiriteID: Int) -> AnyPublisher<Void, Error>
    func remove(favouiriteID: Int) -> AnyPublisher<Void, Error>
}
