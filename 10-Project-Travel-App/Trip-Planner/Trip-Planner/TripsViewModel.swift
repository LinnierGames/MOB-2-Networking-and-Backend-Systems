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
    
    func reload(tripsWith compitionHandler: @escaping (Result<String, TripAPIErrors>) -> ()) {
        //TODO: fetch all trips
    }
    
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
    
    
    
    func reloadUserTrips(complition: () -> ()) {
    }
}
