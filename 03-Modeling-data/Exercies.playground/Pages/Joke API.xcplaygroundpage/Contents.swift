//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

struct Joke: Decodable, CustomStringConvertible {
    let id: Int
    let type: String
    let setup: String
    let punchline: String
    
    var description: String {
        return "\(setup) \(punchline) - \(type)"
    }
}

struct JokeService {
    static let randomJoke = URL(string: "https://08ad1pao69.execute-api.us-east-1.amazonaws.com/dev/random_joke")!
    static let randomTen = URL(string: "https://08ad1pao69.execute-api.us-east-1.amazonaws.com/dev/random_ten")!
    
    let session = URLSession.shared
    
    enum JokeServiceReults {
        case success([Joke])
        case error(String)
    }
    
    func fetchJokes(for url: URL, complition: @escaping (JokeServiceReults) -> ()) {
        let request = URLRequest(url: url)
        session.dataTask(with: request) { (data, reponse, error) in
            guard
                error == nil,
                let result = data
                else {
                    return complition(.error(error!.localizedDescription))
            }
            guard let jokes = try? JSONDecoder().decode([Joke].self, from: result) else {
                    return complition(.error("could not decode to Joke objects"))
            }
            
            complition(.success(jokes))
        }.resume()
    }
}

JokeService().fetchJokes(for: JokeService.randomTen) { (jokes) in
    print(jokes)
}
