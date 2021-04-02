//
//  UserDefaults.swift
//  NotForgot
//
//  Created by administrator on 31.03.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import Foundation

struct UserDefault: Codable {
    var email : String
    var password : String
    var name : String
    var apiToken : String
}
