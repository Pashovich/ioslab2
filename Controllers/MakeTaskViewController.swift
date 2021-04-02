//
//  MakeTaskViewController.swift
//  NotForgot
//
//  Created by administrator on 01.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//


import UIKit
import Alamofire
class MakeTaskViewController: UIViewController{
    var table : InfoTableViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbededInfo"{
            table = segue.destination as! InfoTableViewController
        }

    }
}

