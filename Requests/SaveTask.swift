//
//  SaveTask.swift
//  NotForgot
//
//  Created by administrator on 02.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import Foundation

struct SaveTask : Encodable, Decodable{
    let title : String
    let description : String
    let done : Int
    let deadline : Int
    let category_id : Int
    let priority_id : Int
}
