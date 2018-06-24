//
//  SearchRouter.swift
//  Assignment
//
//  Created by Manasa MP on 24/06/18.
//  Copyright © 2018 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire

enum SearchRouter : URLRequestConvertible {
    
    case get(String)
    
    public func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            
            return .get
        }
        
        let url: URL = {
            
            let url = URL(string: "https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpslimit=10")!
            
            return url
        }()
        
        let params: ([String: Any]) = {
            
            switch self {
            case .get(let searchText):
                
                let dict = ["gpssearch": "\(searchText)"] as [String : Any]
                
                return dict
            }
        }()
        
        let urlRequest = URLRequest(url: url)
        
        let encoding                = URLEncoding.queryString
        var encodedRequest          = try! encoding.encode(urlRequest, with: params)
        
        encodedRequest.httpMethod       = method.rawValue
        encodedRequest.timeoutInterval  = 30
        
        return encodedRequest
    }
}
