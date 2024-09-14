import Foundation

struct MediaSearchResponse: Codable {
    let results: [MediaSearchResult]
}

struct MediaSearchResult: Identifiable, Codable {
    let id: Int
    let title: String?
    let name: String?
    let releaseDate: String?
    let firstAirDate: String?
    let mediaType: String
    let overview: String?
    let posterPath: String?
    let voteAverage: Double

    var displayTitle: String {
        title ?? name ?? "Unknown Title"
    }

    var displayDate: String {
        releaseDate ?? firstAirDate ?? "Unknown Date"
    }

    var fullPosterPath: String? {
        guard let posterPath = posterPath else { return nil }
        return "\(TMDbAPIConfig.imageBaseURL)\(posterPath)"
    }

    enum CodingKeys: String, CodingKey {
        case id, title, name, overview, mediaType = "media_type", posterPath = "poster_path", voteAverage = "vote_average"
        case releaseDate = "release_date", firstAirDate = "first_air_date"
    }
}
