//: [Previous](@previous)

import PlaygroundSupport
PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

import Foundation

struct PokemonAPI {
    static let apiUrl = "https://pokeapi.co/api/v2/"
    
    public static var numberOfPokemons = 949
    
    enum PokemonAPIErrors: Error {
        case InvalidURL
        case BadRequest
    }
    
    private static func get(api relativeUrlString: String?, complition: @escaping (Data?, URLResponse?, PokemonAPIErrors?) -> ()) {
        let apiUrl = URL(string: PokemonAPI.apiUrl)!
        guard
            let relativeUrl = URL(string: relativeUrlString ?? "")
            else {
                return complition(nil, nil, .InvalidURL)
        }
        let requestUrl = apiUrl.appendingPathComponent(relativeUrl.absoluteString, isDirectory: true)
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            complition(data, response, error as? PokemonAPIErrors)
        }.resume()
    }
    
    public static func get(apiUsing urlComponents: URLComponents, complition: @escaping (Data?, URLResponse?, PokemonAPIErrors?) -> ()) {
        guard let urlString = urlComponents.string else {
            return complition(nil, nil, .InvalidURL)
        }
        PokemonAPI.get(api: urlString) { (data, response, error) in
            complition(data, response, error)
        }
    }
    
    public static func fetchAllCharacters(complition: @escaping (_ characters: [[String: Any]]?, _ error: PokemonAPIErrors?) -> ()) {
        var urlComponents = URLComponents(string: "pokemon/")!
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: String(numberOfPokemons))
        ]
        PokemonAPI.get(apiUsing: urlComponents) { (data, response, error) in
            guard error == nil else {
                return complition(nil,error)
            }
            guard
                let result = data,
                let json = try? JSONSerialization.jsonObject(with: result, options: .allowFragments) as! [String: Any],
                let jsonCharacters = json["results"] as! [[String: Any]]?
                else {
                    return complition(nil, .BadRequest)
            }
            complition(jsonCharacters, nil)
        }
    }
    
    public static func fetch(pokemonBy name: String, complition: @escaping (_ character: [String: Any]?, _ error: PokemonAPIErrors?) -> ()) {
    }
}

PokemonAPI.fetch(pokemonBy: "metapod") { (character, error) in
    guard error == nil else {
        print(error)
        return
    }
    guard let pokemon = character else {
        print("could not convert character")
        return
    }
    print(pokemon)
}

PokemonAPI.fetchAllCharacters { (result, error) in
    guard error == nil else {
        print("could not fetch: \(error)")
        return
    }
    guard let pokemons = result else {
        print("Error converting pokemons")
        return
    }
    print(pokemons)
}

//: [Next](@next)
