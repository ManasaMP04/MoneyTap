//
//  SearchResult.swift
//  Assignment
//
//  Created by Manasa MP on 23/06/18.
//  Copyright © 2018 Manasa MP. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

struct SearchResult: Mappable {
    
    var pageid           = 0
    var title            = ""
    var thumbnail        : ThumbnailResult?
    var terms            = [String: Any]()
    
    init?(map: Map) {
        
    }
    
    init(_ pageId: Int, title: String, imageStr: String, desc: String) {
        
        self.pageid = pageId
        self.title = title
        self.thumbnail = ThumbnailResult()
        thumbnail?.source = imageStr
        self.terms = ["descriptionData": desc]
    }
    
    mutating func mapping(map: Map) {
        
        pageid             <- map["pageid"]
        title              <- map["title"]
        thumbnail          <- map["thumbnail"]
        terms              <- map["terms"]
    }
}

struct ThumbnailResult: Mappable {
    
    var source           = ""
    var width            = 0
    var height           = 0
    
    init?(map: Map) {
        
    }
    
    init() {
        
    }
    
    mutating func mapping(map: Map) {
        
        source             <- map["source"]
        width              <- map["width"]
        height             <- map["height"]
    }
}
