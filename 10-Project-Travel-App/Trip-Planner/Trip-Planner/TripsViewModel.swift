//
//  TripsViewModel.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/17/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya
import Result
import SwiftyJSON
import RxSwift
import RxCocoa

class TripsViewModel {
    private var apiProvider = MoyaProvider<TripAPIEndpoints>()
    
    private var trips = [TPTrip]()
    
    func arrayOfTrips() -> [TPTrip] {
        return trips.sorted(by: { (a, b) -> Bool in
            return a.title < b.title
        })
    }
    
    func removeTrip(at index: Int) {
        self.trips.remove(at: index)
    }
    
//    private let privateDataSource: Variable<[String]> = Variable([])
//    private let disposeBag = DisposeBag()
//
//    // MARK: Outputs
//    public lazy var dataSource: Observable<[String]> = {
//        return self.privateDataSource.asObservable()
//    }()
    
    enum TripAPIErrors: Error {
        case Message(String)
        case InvalidUserCerdentials
        case ServerError
        
        var localizedDescription: String {
            switch self {
            case .Message(let message):
                return message
            default:
                return String(describing: self)
            }
        }
    }
    
    /**
     Fetch all of the trips
     
     - warning: a user must be already authenticated and logged in
     */
    func reloadTrips(complition: @escaping (Result<String, TripAPIErrors>) -> ()) {
        guard
            let user = PersistenceStack.loggedInUser
            else {
                preconditionFailure("not user was logged in")
        }
        
        apiProvider.request(.Trips(for: user.jsonBody)) { (result) in
            switch result {
            case .success(let res):
                guard let message = JSON(res.data).dictionary?["message"]?.string else {
                    return assertionFailure("failed to get message from json")
                }
                
                switch res.statusCode {
                case 202:
                    guard let tripsJson = JSON(res.data).dictionary?["data"],
                        let tripsData = try? tripsJson.rawData(),
                        let trips = try? JSONDecoder().decode([TPTrip].self, from: tripsData)
                        else {
                            return assertionFailure("could not decode into TPTrips")
                    }
                    
                    self.trips = trips
                    
                    complition(.success(message))
                case 401, 404, 400:
                    complition(.failure(.Message(message)))
                case 500:
                    complition(.failure(.ServerError))
                default:
                    fatalError("Unhandled status code")
                }
            case .failure(let error):
                complition(.failure(.Message(error.localizedDescription)))
            }
        }
    }
    
    /**
     Insert a new trip to the logged in user
     
     - parameter trip: what trip to add
     */
    func add(a trip: TPTrip, complition: @escaping (Result<String, TripAPIErrors>) -> ()) {
        apiProvider.request(.AddTrip(trip.jsonBody)) { (result) in
            switch result {
            case .success(let res):
                guard let message = JSON(res.data).dictionary?["message"]?.string else {
                    return assertionFailure("failed to get message from json")
                }
                
                switch res.statusCode {
                case 201:
                    self.trips.insert(trip, at: 0)
                    
                    complition(.success(message))
                case 401, 404, 400:
                    complition(.failure(.Message(message)))
                case 500:
                    complition(.failure(.ServerError))
                default:
                    fatalError("Unhandled status code")
                }
            case .failure(let error):
                complition(.failure(.Message(error.localizedDescription)))
            }
        }
    }
    
    /**
     Patch a trip
     
     - parameter trip: trip to update
     */
    func update(a trip: TPTrip, complition: @escaping (Result<String, TripAPIErrors>) -> ()) {
        apiProvider.request(.Update(trip.jsonBody)) { (result) in
            switch result {
            case .success(let res):
                guard let message = JSON(res.data).dictionary?["message"]?.string else {
                    return assertionFailure("failed to get message from json")
                }
                
                switch res.statusCode {
                case 202:
                    complition(.success(message))
                case 401, 404, 400:
                    complition(.failure(.Message(message)))
                case 500:
                    complition(.failure(.ServerError))
                default:
                    fatalError("Unhandled status code")
                }
            case .failure(let error):
                complition(.failure(.Message(error.localizedDescription)))
            }
        }
    }
    /**
     Delete a trip
     
     - parameter trip: trip to update
     */
    func delete(a trip: TPTrip, complition: @escaping (Result<String, TripAPIErrors>) -> ()) {
        apiProvider.request(.Delete(trip.jsonBody)) { (result) in
            switch result {
            case .success(let res):
                guard let message = JSON(res.data).dictionary?["message"]?.string else {
                    return assertionFailure("failed to get message from json")
                }
                
                switch res.statusCode {
                case 202:
                    complition(.success(message))
                case 401, 404, 400:
                    complition(.failure(.Message(message)))
                case 500:
                    complition(.failure(.ServerError))
                default:
                    fatalError("Unhandled status code")
                }
            case .failure(let error):
                complition(.failure(.Message(error.localizedDescription)))
            }
        }
    }
}
