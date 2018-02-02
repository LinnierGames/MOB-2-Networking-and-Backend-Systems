//
//  ProductNetworkService.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation

struct IfError {
    @discardableResult
    init?(_ error: Error?) {
        if let err = error {
            assertionFailure(err.localizedDescription)
            return nil
        }
    }
    
    @discardableResult
    init?(_ error: Error?, handler: (Error) -> Void) {
        if let err = error {
            handler(err)
            return nil
        }
    }
}

public struct ProductNetworkService {
    public static let baseUrl = URL(string: "https://api.producthunt.com/v1/")!
    
    private static var session = URLSession.shared
    
    public enum ProductNetworkCalls {
        case FetchAllProductsForToday
    }
    
    public enum ResultType<T> {
        case Success(T)
        case Failed(String)
    }
    
    public static func fetchProducts(for newtworkCall: ProductNetworkCalls, resultHandler: @escaping (ResultType<[Product]>) -> ()) {
        var request: URLRequest
        switch newtworkCall {
        case .FetchAllProductsForToday:
            request = URLRequest(url: baseUrl.appendingPathComponent("posts"))
            break
        }
        request.allHTTPHeaderFields = [
            "Host": "api.producthunt.com",
            "Authorization": "Bearer 40d589a0340b7659eddeca24cdfe28f43337b684fbae6ef85c9e228ebeb0b1b4",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        session.dataTask(with: request) { (data, response, error) in
            IfError(error) { err in
                resultHandler(.Failed(err.localizedDescription))
            }
            
            guard
                let result = data,
                let postsResult = try? JSONDecoder().decode(PostsResult.self, from: result) else {
                    assertionFailure("Failed to decode json into swift models")
                    
                    return resultHandler(.Failed("Failed to create Product list"))
            }
            
            resultHandler(.Success(postsResult.posts))
        }.resume()
    }
}
