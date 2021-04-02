//
//  APIHandler.swift
//  NotForgot
//
//  Created by administrator on 02.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//


import Foundation
import Alamofire

class APIHandler{
    static func getApiToken() -> String{
        let userDefaults = UserDefaults.standard
        do {
            let playingItMyWay = try userDefaults.getObject(forKey: "data", castTo: UserDataStruct.self)
            return playingItMyWay.api_token
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    static func getHeaders() -> HTTPHeaders{
        let apiToken = APIHandler.getApiToken()
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer " + apiToken,
            "Accept-Encoding" : "gzip, deflate, br",
            "Accept" : "*/*"
        ]
        return headers
    }

}
