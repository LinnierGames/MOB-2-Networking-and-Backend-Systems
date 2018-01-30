//: [Previous](@previous)

import Foundation
import PlaygroundSupport

class Anime: Decodable {
    
    let type: String //animie
    let links: [String: String] //links to maybe itself
    
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
            
            let json = try! JSONSerialization.jsonObject(with: result, options: .allowFragments) as! [String: Any]
            let animeJson = json["data"] as! [String: Any]
            let animeData = try! JSONSerialization.data(withJSONObject: animeJson, options: .prettyPrinted)
            
            guard let ani = try? JSONDecoder().decode(Anime.self, from: animeData) else {
                return complition(.CouldNotDecode)
            }
            complition(.Success(ani))
        }.resume()
    }
}

AnimeService().fetch { (anime) in
    switch anime {
    case .Success(let animeObj):
        print(animeObj.links)
    default:
        break
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true











class Person {
    let name: String
    var age: Int? = nil
    
    init(name: String, age: Int?) {
        self.name = name
        self.age = age
    }
}

let pepole = [Person(name: "hi", age: nil),Person(name: "hi", age: nil),Person(name: "hi", age: nil)]

pepole[0].age = 5

pepole[0]

for i in 0..<pepole.count {
    pepole[i].age = 5
}

pepole
let results = pepole.map {Person(name: $0.name, age: 5)}




//: [Next](@next)
