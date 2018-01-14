import Foundation
import PlaygroundSupport
import UIKit

//: [Previous](@previous)

/*:
 # Downloading JSON
 
 More often than not, we will be dealing with JSON responses from servers.
 Lets look at how we will grab some json from an API using a *get* request.
 
 ## JSON
 
 JSON stands for Javascript Object Notation.
 It is one of a few formats that is used to transfer information over the web.
 JSON looks like this:
 {
 "name": "Eliel"
 "age": 23
 }
 
*/

let url = URL(string: "https://jsonplaceholder.typicode.com/photos/1")!

var request = URLRequest(url: url)
request.httpMethod = "GET"

let session = URLSession.shared

struct Photo : Decodable {
    var id: Int
    var title: String
    var albumId: Int
    var url: String
    var thumbnailUrl: String
    var image: UIImage? = nil
    
//    required convenience init?(from aDecoder: Decoder) {
//        var container = try! aDecoder.container(keyedBy: CodingKeys.self)
//        var nestedContainer = try! container.nested
//        guard
//            let idValue = try? container.decode(Int.self, forKey: .id),
//            let titleValue = try? container.decode(String.self, forKey: .title)
//            else {
//                return nil
//        }
//
//        let hola: String? = nil
//        let somethingWrong = hola ?? "Hi"
//
//        self.id = idValue
//    }
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case albumId
        case url
        case thumbnailUrl
    }
}

session.dataTask(with: URL(string: "http://httpbin.org/get?id=1&albumId=1&title=accusamus%20beatae%20ad%20facilis&url=http://placehold.it/600/92c952")!) { (data, response, error) in
    guard
        let result = data,
        let json = try? JSONSerialization.jsonObject(with: result, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any],
        let args = try? JSONSerialization.data(withJSONObject: json["args"] as! [String: Any], options: JSONSerialization.WritingOptions.prettyPrinted),
        let photo = try? JSONDecoder().decode(Photo.self, from: args)
        else {
            return
    }
    
    print(photo.albumId)
    
}.resume()

let task = session.dataTask(with: request) { (data, response, error) in
    guard let data = data else {
        return
    }
    //ASK: Why use JSONSerialization?
    let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    UserDefaults.standard.set(json, forKey: "aPhoto")
    var photo = try! JSONDecoder().decode(Photo.self, from: data)
    session.dataTask(with: URL(string: photo.url)!, completionHandler: { (data, res, err) in
        guard let data = data else { return }
        photo.image = UIImage(data: data)
    }).resume()
    
}

// Don't forget to resume task
task.resume()


/*:
 ## Sessions
 
 There are three main session types:
 1. session.uploadTask   :- Used for uploading binary files
 2. session.downloadTask :- Used for downloading binary files
 3. session.dataTask     :- Used for uploading and downloading and deleting text/html/json
 
 
 */

/*:
 ## Uploading JSON data
 
 We often need to upload data to our servers.
 Imagine creating a new user account for an app, we would need to upload information about the user necessary to create the account.
 */

/*:
 JSON in Swift is represented as a dictionary with a String key to an Any type as the value
 
 Why is that so? Lets take a look at the structure of a JSON Object.
 {
 "user": {
 "age": 23,
 "name": "peter",
 "location": [27.33, -122]
 }
 }
 
 From the example above we can see that the keys are always Strings and the values can be *Any* type of object(Int, String, Array, another JSON Object).
 
 */

//: ### Uploading JSON data
//: Lets define our JSON type as a dictionary of String to Any
typealias JSON = [String: Any]

var postReq = URLRequest(url: URL(string: "https://httpbin.org/post")!)

let jsonDictionary: JSON = ["user": ["first_name": "Eliel", "last_name": "Gordon"]]
let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)

postReq.httpMethod = "POST"
postReq.httpBody = jsonData

session.dataTask(with: postReq) { (data, resp, err) in
    if let data = data {
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let stringJson = String(data: data, encoding: .utf8)
        //print(json)
    }
}.resume()


/*:
 ## Challenges

 1. Can you think of a type safe way to wrap the http methods of a request?
 2. Find some JSON API resources online and use URLSession to download the JSON

*/

struct GoogleShortLinker {
    static let baseUrl = "https://www.googleapis.com/urlshortener/v1/url"
    
    //super secret
    var apiKey: String
    
    /// Creates a url with the key=apiKey as a query string
    var postUrl: URL {
        var urlComponents = URLComponents(string: GoogleShortLinker.baseUrl)!
        urlComponents.query = "key=\(apiKey)"
        
        return urlComponents.url!
    }
    
    /**
     Creates a get url, to search for its long url, with shortenUrl in the 'query string' of the url as
     shortUrl=url. This call includes the apiKey as well
     
     - Parameter shortenUrl:   The url to search for
     
     - Returns: A url used to get the long url, nil if the shorten string url
     is invalid
     */
    func getUrl(for shortenUrl: String) -> URL? {
        var urlComponents = URLComponents(string: GoogleShortLinker.baseUrl)!
        urlComponents.query = "shortUrl=\(shortenUrl)&key=\(apiKey)"
        guard let url = urlComponents.url else {
            return nil
        }
        
        return url
    }
    
    enum POSTShortLinkError: Error {
        case InvalidURL
        case BadRequest
    }
    
    enum GETShortLinkError: Error {
        case InvalideURL
        case BadRequest
        case LongURLNotFound
    }
    
    /**
     Fires a POST request to the baseUrl with the long url serialized in a json
     object using the set apiKey
     
     - Parameter longUrlString:   The url to shorten
     
     - Parameter complition: (Result, Error) If no error is present, invalid url
     , bad request, result will contain the deserialized json object with the
     shorten url
     */
    func post(longUrlString: String, complition: @escaping (_ callBack: [String: Any]?, _ error: POSTShortLinkError?) -> ()) {
        var request = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let longUrl = URL(string: longUrlString) else {
            return complition(nil, .InvalidURL)
        }
        let jsonRequest = ["longUrl": longUrl.absoluteString]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonRequest, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                let response = data,
                let json = try? JSONSerialization.jsonObject(with: response, options: .allowFragments) as! [String: Any]
                else {
                return complition(nil, .BadRequest)
            }
            complition(json, nil)
            
        }.resume()
    }
    
    /**
     Fires a GET request to the baseUrl with the shorten url in the 'query
     string' of the url and returns a json object with its long url.
     
     - Parameter longUrlFrom:   The url to search for its long url
     
     - Parameter complition: (Result, Error) If no error is present, invalid url
     , bad request, result will contain the deserialized json object with the
     long url
     */
    func get(longUrlFrom shortenUrl: String, complition: @escaping (_ callBack: [String: Any]?, _ error: GETShortLinkError?) -> ()) {
        //make reqeust with GET
        guard let getUrl = getUrl(for: shortenUrl) else {
            return complition(nil, .InvalideURL)
        }
        var request = URLRequest(url: getUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //fire request
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                let response = data,
                let json = try? JSONSerialization.jsonObject(with: response, options: .allowFragments) as! [String: Any]
                else {
                    return complition(nil, .BadRequest)
            }
            
            complition(json, nil)
        }.resume()
    }
}

let service = GoogleShortLinker(apiKey: "AIzaSyB-56-tOTd0wNhIf1Rz7VCp1tglhXOhFoU")
service.post(longUrlString: "http://www.google.com/") { (data, err) in
    guard err == nil else {
        print(err!)
        return
    }
    print(data!)
}

service.get(longUrlFrom: "https://goo.gl/fbsS") { (result, error) in
    guard error == nil else {
        print("Failed")
        return
    }
    
    print(result!)
}

/*: ##Resources
 
 [URLSessions](https://www.raywenderlich.com/158106/urlsession-tutorial-getting-started)
 
 */

//: Below is code required to run this playground, it is not a part of the class material
PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
