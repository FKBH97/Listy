import Foundation

// Response model for TMDb search results
struct MediaSearchResponse: Codable {
    let results: [MediaSearchResult]
}

// Individual media search result
struct MediaSearchResult: Identifiable, Codable {
    let id: Int
    let title: String?
    let name: String?
    let releaseDate: String?
    let mediaType: String?
    let overview: String?
    let posterPath: String?
    let voteAverage: Double?
    
    // Additional computed properties to handle optional values
    var displayTitle: String {
        return title ?? name ?? "Unknown Title"
    }
    
    var displayDate: String {
        return releaseDate ?? "Unknown Date"
    }

    var fullPosterURL: URL? {
            guard let posterPath = posterPath else { return nil }
            return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        }
    
    enum CodingKeys: String, CodingKey {
            case id, title, name, overview
            case releaseDate = "release_date"
            case mediaType = "media_type"
            case posterPath = "poster_path"
            case voteAverage = "vote_average"
        }
        
}
