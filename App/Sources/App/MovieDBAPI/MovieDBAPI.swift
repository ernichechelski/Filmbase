//
//  MovieDBAPI.swift
//
//
//  Created by Ernest Chechelski on 12/12/2023.
//

import Foundation
import Combine
import UIKit

struct Movie {
    let id: Int
    let title: String
    let image: UIImage
    let releseDate: Date
    let grade: Float
    let overview: String
    let isFavourite: Bool
}

protocol MoviesRequest {
    var basePath: String { get }
    var subpath: String? { get }
}

extension MoviesRequest where Self: PerformerRequest {
    var basePath: String {
        "https://api.themoviedb.org"
    }

    var path: String? { basePath + (subpath ?? "") }
}

enum Movies {
    struct GetMovies: RequestPerformerType {
        struct Request: PerformerRequest, MoviesRequest {
            var subpath: String? {
                "/3/movie/now_playing"
            }
            
            struct QueryItems: Encodable {
                var page: Int
                var language: String
                enum CodingKeys: String, CodingKey {
                    case page = "page"
                    case language = "language"
                }
            }
            
            struct Headers: Encodable {
                var accept = "application/json"
                var authorisation: String
                enum CodingKeys: String, CodingKey {
                    case accept = "accept"
                    case authorisation = "Authorization"
                }
            }
        }

        struct Response: PerformerResponse {
            struct Body: Decodable {
                let dates: Dates
                let page: Int
                let results: [Movie]
                let totalPages, totalResults: Int

                enum CodingKeys: String, CodingKey {
                    case dates, page, results
                    case totalPages = "total_pages"
                    case totalResults = "total_results"
                }
                
                // MARK: - Dates
                struct Dates: Codable {
                    let maximum, minimum: String
                }

                // MARK: - Result
                struct Movie: Codable {
                    let adult: Bool
                    let backdropPath: String?
                    let genreIDS: [Int]
                    let id: Int
                    let originalLanguage: String
                    let originalTitle, overview: String
                    let popularity: Double
                    let posterPath, releaseDate, title: String
                    let video: Bool
                    let voteAverage: Double
                    let voteCount: Int

                    enum CodingKeys: String, CodingKey {
                        case adult
                        case backdropPath = "backdrop_path"
                        case genreIDS = "genre_ids"
                        case id
                        case originalLanguage = "original_language"
                        case originalTitle = "original_title"
                        case overview, popularity
                        case posterPath = "poster_path"
                        case releaseDate = "release_date"
                        case title, video
                        case voteAverage = "vote_average"
                        case voteCount = "vote_count"
                    }
                }
            }
        }
    }
}
