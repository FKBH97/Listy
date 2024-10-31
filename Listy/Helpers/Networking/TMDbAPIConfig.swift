import Foundation

struct TMDbAPIConfig {
    static let shared = TMDbAPIConfig()
    let apiAccessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiZTI4MWFjNDI2N2RiOGVlODk3OGE5NTY1YzI5YmUwZCIsIm5iZiI6MTcyNjMzNDM3Ni42ODExOTMsInN1YiI6IjY2ZTM3NDhkYzgxYjI0YjNmZTIzY2U2ZiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.F80PLtUlxXQ5DaeG4tU84bcu3FUotSOAShJe8lEyJ7E"
    static let baseURL = "https://api.themoviedb.org/3"
    static let apiKey = "be281ac4267db8ee8978a9565c29be0d"  // Replace with your actual TMDB API key
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    private init() {}
}
