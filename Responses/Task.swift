//
//  Task.swift
//  NotForgot
//
//  Created by administrator on 02.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import Foundation

//struct Task : Decodable {
//    var id : Int
//    var title : String
//    var description : String
//    var done : Int
//    var deadline : Int
//    var created : Int
//    struct CategoryResponseStructure : Decodable {
//        var name : String
//        var id : Int
//    }
//    struct PriorityResponseStructure : Decodable {
//        var name : String
//        var id : Int
//        var color : String
//    }
//    enum RealInfoKeys: String, CodingKey {
//        case fullName = "full_name"
//    }
//    var priority : PriorityStruct
//    var category : CategoryStruct
//}

struct RawServerResponse: Decodable {

    struct CategoryResponseStructure: Decodable {
        var name : String
        var id : Int
    }

    struct PriorityResponseStructure: Decodable {
        var name : String
        var id : Int
        var color : String
    }

    var id : Int
    var title : String
    var description : String
    var done : Int
    var deadline : Int
    var created : Int
    var category : CategoryResponseStructure
    var priority : PriorityResponseStructure
}


/*
 {
   "id": 1,
   "title": "Study hard",
   "description": "Or die trying",
   "done": 1,
   "deadline": 1570963029,
   "category": {
     "id": 2,
     "name": "University"
   },
   "priority": {
     "id": 2,
     "name": "Important",
     "color": "#E7004D"
   },
   "created": 1570963029
 }
 */
