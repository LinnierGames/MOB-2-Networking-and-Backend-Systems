import PlaygroundSupport
import Foundation

/*:
 # URLs, URLRequests and URLSessions
 
 
 ## URL - Uniform Resource Locator
 
 ### Types of Requests
 These are the 4 main REST request types we will be looking at:-
 They each perform a specific role in http networking.
 
 - GET   :- Fetches a resource
 - POST  :- Creates a new resource
 - PUT/PATCH/UPDATE:- Updates a resource
 - DELETE:- Deletes a resource
*/



/*:
 ## Constructing URLRequests
 
 ### Creating a get request to download an html webpage
 
 To create a network request in iOS, there are 3 main parts to it.
 
 1. First construct a url for the resource you want to get/update/delete/create
 2. Create a URLRequest with the URL
 3. Create a URLSession with the URLRequest
 
 
*/

// 1
let url = URL(string: "www.google.com/images/434.png")!

//let body = JSONSerialization.data(withJSONObject: ["name": "eliel"], options: JSONSerialization.WritingOptions.prettyPrinted)
// 2
var request = URLRequest(url: url)
request.httpMethod = "GET"
//request.httpBody =


typealias JSON = [String: Any]

// 3
let session = URLSession.shared

// 4
let downloadTask = session.dataTask(with: request) { (data, response, error) in
    
   // _ = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
    
    
}

// 5
downloadTask.resume()


/*:
 ### URLRequest
 Depending on what kind of request you are making(post,get etc..), you will need to
 change the http method and add a body.
 
 ### URLSession
 The session has information about the request to be made. It is also responsible for executing the network request.
 Calling *resume()* on the task returned by the session kicks off the network request.
 
*/

class Person : Codable {
    
    var name: String
    var birthday: Date
    var age: Int {
        return 0
    }
    var ssn: String = "000-00-000"
    
    init(name: String, dob: Date = Date()) {
        self.name = name
        self.birthday = dob
    }
    
    enum CodingKeys: CodingKey {
        case name
        case birthday
        //dont serialize ssn
    }
}

let person = Person(name: "erick")
let personData = try! JSONEncoder().encode(person)
let personJson = String(data: personData, encoding: String.Encoding.utf8)
let aPerson = try! JSONDecoder().decode(Person.self, from: personData)

class Human: NSObject, NSCoding {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard
            let name = aDecoder.decodeObject(forKey: "name") as? String
            else {
                return nil
        }
        self.name = name
    }
}

let human = Human(name: "Erick")
let humanData = try! JSONSerialization.data(withJSONObject: human, options: .prettyPrinted)
let humanJson = String(data: humanData, encoding: .utf8)!

let aHuman = try! JSONSerialization.jsonObject(with: humanData, options: .allowFragments) as! Human


//: [Next](@next)


//: Below is code required to run this playground, it is not a part of the class material
PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true
