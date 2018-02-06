//
//  ProductNetworkService.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya

public struct ProductNetworkService {
    
    private static var productHuntAPI = MoyaProvider<ProductHuntAPIEndPoints>()
    
    public enum ResultType<T> {
        case Success(T)
        case Failed(String)
    }
    
    public static func fetchProducts(resultHandler: @escaping (ResultType<[Product]>) -> ()) {
        productHuntAPI.request(.TodaysProducts) { (result) in
            switch result {
            case .success(let response):
                guard
                    let postsResult = try? JSONDecoder().decode(PostsResult.self, from: response.data) else {
                        assertionFailure("Failed to decode json into swift models")
                        DispatchQueue.main.async {
                            resultHandler(.Failed("Failed to create Product list"))
                        }
                        
                        return
                }
                
                resultHandler(.Success(postsResult.posts))
            case .failure(let err):
                resultHandler(.Failed(err.localizedDescription))
            }
        }
    }

    public static func fetchComments(for product: Product, resultHandler: @escaping (ResultType<[CommentsResult.Comment]>) -> ()) {
        productHuntAPI.request(.Comments(for: product)) { (result) in
            switch result {
            case .success(let response):
                guard let commentsResult = try? JSONDecoder().decode(CommentsResult.self, from: response.data) else {
                        assertionFailure("Failed to decode json into swift models")
                        DispatchQueue.main.async {
                            resultHandler(.Failed("Failed to create Product list"))
                        }
                        
                        return
                }
                
                resultHandler(.Success(commentsResult.comments))
            case .failure(let err):
                resultHandler(.Failed(err.localizedDescription))
            }
        }
    }
}
