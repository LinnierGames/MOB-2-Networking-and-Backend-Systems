//: [Previous](@previous)

import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

class ListingSearchResult: Decodable {
    
    let results: [Result]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: searchCodingKeys.self)
        results = try container.decode([Result].self, forKey: .results)
    }
    
    enum searchCodingKeys: String, CodingKey {
        case results = "search_results"
    }
    
}

class Result: Decodable {
    let listing: Listing
    let pricingQuote: PricingQuote
    let viewedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case listing
        case pricingQuote = "pricing_quote"
        case viewedAt = "viewed_at"
    }
}

struct Listing: Decodable {
    let city: String
    let beds: Int
    let bedrooms: Int
    let localizedCity: String
    
    enum CodingKeys: String, CodingKey {
        case city
        case beds
        case bedrooms
        case localizedCity = "localized_city"
    }
}

struct PricingQuote: Decodable {
    let available: Bool
    let guests: Int
    let localizedNightlyPrice: Int
    
    enum CodingKeys: String, CodingKey {
        case available
        case guests
        case localizedNightlyPrice = "localized_nightly_price"
    }
}

struct BNBService {
    let baseUrl = URL(string: "https://api.airbnb.com/v2/search_results?key=915pw2pnf4h1aiguhph5gc5b2")!
    
    var session = URLSession.shared
    
    enum BNBResultType {
        case Success(ListingSearchResult)
        case Failed(String)
    }
    
    func fetch(resultHanlder: @escaping (BNBResultType) -> ()) {
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: "915pw2pnf4h1aiguhph5gc5b2")
        ]
        let request = URLRequest(url: urlComponents.url!)
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else { return resultHanlder(.Failed(error!.localizedDescription)) }
            
            guard
                let result = data,
                let resultsOfListings = try? JSONDecoder().decode(ListingSearchResult.self, from: result)
                else {
                    return resultHanlder(.Failed("something went wrong"))
            }
            
            resultHanlder(.Success(resultsOfListings))
        }.resume()
    }
}

BNBService().fetch { (result) in
    
    switch result {
    case .Success(let results):
        for result in results.results {
            print(result.listing.city)
        }
    case .Failed(let errorMessage):
        print(errorMessage)
    }
}

//: [Next](@next)
