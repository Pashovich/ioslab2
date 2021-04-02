//
//  Register.swift
//  NotForgot
//
//  Created by administrator on 31.03.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import Foundation


struct RegisterResonse : Decodable {
    var email : String
    var name : String
    var api_token : String
    var id : Int
}
