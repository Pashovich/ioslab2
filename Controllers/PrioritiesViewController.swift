//
//  CategoriesTableViewController.swift
//  NotForgot
//
//  Created by administrator on 01.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import UIKit
import Alamofire


struct ProrityData: Encodable {
    let name : String
}
struct Priorities: Codable {
    let name: String
    let id: Int
    let color : String
}

class PrioritiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate : ProDelegate?
    @IBOutlet weak var navigationBar: UINavigationItem!
    var api_token : String!
    var done = false
    var priorities : [PriorityStruct]!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let a = self.priorities[indexPath.row]
        self.delegate?.selectPriority(priority:  a)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.priorities == nil{
            return 0
        }
        return self.priorities.count
    }
    private func getApiToken() -> String{
        let userDefaults = UserDefaults.standard
        do {
            let playingItMyWay = try userDefaults.getObject(forKey: "data", castTo: UserDataStruct.self)
            return playingItMyWay.api_token
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    private func getHeaders() -> HTTPHeaders{
        let apiToken = self.getApiToken()
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer " + apiToken,
            "Accept-Encoding" : "gzip, deflate, br",
            "Accept" : "*/*"
        ]
        return headers
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = self.priorities[indexPath.row].name
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        self.loadCategories()
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
//        tableView.alwaysBounceVertical = true
        tableView.delegate = self
        tableView.dataSource = self
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem(title: "SomeTitle")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(handleClosure))
        doneItem.title = "Cancel"
        navItem.leftBarButtonItem = doneItem

        navBar.setItems([navItem], animated: false)
    }
    @objc func handleClosure(){
        self.dismiss(animated: true, completion: nil)
    }
    private func loadCategories(){
        let string = API.baseURL + "priorities"
        let url = NSURL(string: string)
        let request = NSMutableURLRequest(url: url! as URL)
        request.setValue("Bearer " + self.getApiToken(), forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        self.priorities = [PriorityStruct]()
        let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data
            {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if  let object = json as? [Any] {
                        for anItem in object as! [Dictionary<String, AnyObject>] {
                            let priorityName = anItem["name"] as! String
                            let priorityID = anItem["id"] as! Int
                            let priorityColor = anItem["color"] as! String
                            let structData = PriorityStruct(name: priorityName, color: priorityColor, id: priorityID)
                            self.priorities.append(structData)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
//                        semaphore.signal()
                    }
                } catch {
                    print(error)
                }
                
            }
        }
        mData.resume()
    }

}
