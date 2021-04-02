//
//  Protocols.swift
//  NotForgot
//
//  Created by administrator on 02.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import Foundation
protocol ProDelegate{
    func selectPriority(priority : PriorityStruct)
}
protocol SelectedCategoryDelegate {
    func selectCategory(category : CategoryStruct)
}
protocol TaskDelegate {
    func updateInfo(data : RawServerResponse)
    func updateInfo()
}
