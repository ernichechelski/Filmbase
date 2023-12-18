//
//  MovieDBAPISchema.swift
//
//
//  Created by Ernest Chechelski on 12/12/2023.
//

import Foundation
import ApiClient

enum Movies {
  struct GetMovies: RequestPerformerType {
    struct Request: PerformerRequest, MoviesRequest {
      var subpath: String? { "/3/movie/now_playing" }

      struct QueryItems: Encodable {
        let page: Int
        let language: String
      }

      struct Headers: Encodable {
        let authorisation: String
        let accept = "application/json"

        enum CodingKeys: String, CodingKey {
          case authorisation = "Authorization"
          case accept
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

        struct Dates: Codable {
          let maximum, minimum: String
        }

        struct Movie: Codable {
          let adult: Bool
          let backdropPath: String?
          let genreIDS: [Int]
          let id: Int
          let originalLanguage: String
          let originalTitle, overview: String
          let popularity: Double
          let posterPath: String?
          let releaseDate, title: String
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
  
  struct GetMovieSearchSuggestionsMovies: RequestPerformerType {
    struct Request: PerformerRequest, MoviesRequest {
      var subpath: String? { "/3/search/movie" }

      struct QueryItems: Encodable {
        let query: String
        let page: Int
        let language: String
      }
      
      typealias Headers = GetMovies.Request.Headers
    }

    struct Response: PerformerResponse {
      struct Body: Decodable {
        let page: Int
        let results: [Movie]
        let totalPages, totalResults: Int

        enum CodingKeys: String, CodingKey {
          case page, results
          case totalPages = "total_pages"
          case totalResults = "total_results"
        }
        
        struct Movie: Codable {
          let originalTitle: String

          enum CodingKeys: String, CodingKey {
            case originalTitle = "original_title"
          }
        }
      }
    }
  }
}

// MARK: Common for whole schema.

protocol MoviesRequest {
  var basePath: String { get }
  var subpath: String? { get }
}

extension MoviesRequest where Self: PerformerRequest {
  var basePath: String { MoviesDBConstants.baseApiPath }
  var path: String? { basePath + (subpath ?? "") }
}

enum MoviesDBConstants {
  static let baseApiPath = "https://api.themoviedb.org"
  static let basePostersPath = "https://image.tmdb.org/t/p/original"
}

extension Movies.GetMovies.Request.Headers {
  init(token: String) {
    self.init(authorisation: "Authorization: Bearer \(token)")
  }
}
