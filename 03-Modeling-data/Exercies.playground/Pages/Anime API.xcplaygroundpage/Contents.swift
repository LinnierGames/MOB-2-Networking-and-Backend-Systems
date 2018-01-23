//: [Previous](@previous)

import Foundation
import PlaygroundSupport

struct Anime: Decodable {
    let type: String //animie
    let links: [String] //links to maybe itself
    
    struct AnimeAttributes: Decodable {
        let createdAt: Date
        let updatedAt: Date
        let slug: String
        let synopsis: String
        let coverImageTopOffset: Float
        let titles: [String]
        let canonicalTitle: String
        let abbreviatedTitles: [String]
        let averageRating: Float
        //let ratingFrequencies: {int, int}
        let userCount: Int
        let favoritesCount: Int
        let startDate: Date
        let endDate: Date
        let popularityRank: Int
        let ratingRank: Int
        let ageRating: String
        let ageRatingGuide: String
        let subtype: String
        let status: String
        let tba: String
        
        struct ASImage: Decodable {
            let tiny: String
            let small: String
            let medium: String
            let large: String
            let original: String
            //let meta: {}
        }
        let posterImage: ASImage
        let coverImage: ASImage
    }
    let attributes: AnimeAttributes
    
    struct Relationship: Decodable {
        struct Links: Decodable {
            let `self`: String
            let related: String
        }
        let genres: Links
        let categories: Links
        let castings: Links
        let installments: Links
        let mappings: Links
        let reviews: Links
        let mediaRelationships: Links
        let episodes: Links
        let streamingLinks: Links
        let animeProductions: Links
        let animeCharacters: Links
        let animeStaff: Links
    }
    let relationships: Relationship
}

let toFetch = URL(string: "https://kitsu.io/api/edge/anime/1")!

struct AnimeService {
    let session = URLSession.shared
    
    enum AnimeErrors {
        case BadRequest(String)
        case CouldNotDecode
        case Success(Anime)
    }
    
    func fetch(complition: @escaping (AnimeErrors) -> ()) {
        let request = URLRequest(url: toFetch)
        session.dataTask(with: request) { (data, response, error) in
            guard
                error == nil,
                let result = data
                else {
                    return complition(.BadRequest(error!.localizedDescription))
            }
            guard let ani = try? JSONDecoder().decode(Anime.self, from: result) else {
                return complition(.CouldNotDecode)
            }
            complition(.Success(ani))
        }.resume()
    }
}

AnimeService().fetch { (anime) in
    print(anime)
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
