//
//  MainViewController.swift
//  NotForgot
//
//  Created by administrator on 31.03.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
extension Sequence where Iterator.Element: Hashable {

    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tasksGrouped : [[RawServerResponse]]!
    var uniqueSections : [Int]!
    var numberOfSections : Int!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasksGrouped[section].count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.tasksGrouped[section].count == 0){
            return ""
        }
        return self.tasksGrouped[section][0].category.name
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 20, y: 8, width: 320, height: 20)
        myLabel.font = UIFont.boldSystemFont(ofSize: 18)
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)

        let headerView = UIView()
        headerView.addSubview(myLabel)

        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = view.backgroundColor
        return headerView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(identifier: "TaskControllerId") as! TaskViewController
        vc.modalPresentationStyle = .fullScreen
        vc.data = self.tasksGrouped[indexPath.section][indexPath.row]
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.deleteItem(item: self.tasksGrouped[indexPath.section][indexPath.row].id)
            self.tasksGrouped[indexPath.section].remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = self.tasksGrouped[indexPath.section][indexPath.row].title
        cell.textLabel?.textColor = .black
        cell.layer.cornerRadius = 9
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor.white.cgColor
        let cellColor = UIColor(hexString: self.tasksGrouped[indexPath.section][indexPath.row].priority.color)
        cell.backgroundColor = cellColor
        let b = CheckBoxButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        cell.addSubview(b)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.numberOfSections == nil){
            return 0
        }
        return self.numberOfSections
    }
    private func calcNumberOfSections(){
        var a = [Int]()
        for item in self.tasks{
            a.append(item.category.id)
        }
        self.uniqueSections = a.unique()
        self.numberOfSections = a.unique().count
    }
    private func makeDataGrouped(){
        self.tasksGrouped = [[RawServerResponse]]()
        for i in 0..<self.numberOfSections{
            self.tasksGrouped.append([])
            for item in self.tasks{
                if (self.uniqueSections[i] == item.category.id){
                    self.tasksGrouped[i].append(item)
                }
            }
        }
    }
    var tasks : [RawServerResponse]!
    var tableView : UITableView!
    var loaded  = false
    var refreshControl = UIRefreshControl()
    @objc func exitController(){
        UserDefaults.standard.removeObject(forKey: "data")
        let vc = storyboard?.instantiateViewController(identifier: "LoginId") as! LoginViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
    }
    private func makeTableView(){
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 30, width: view.frame.size.width, height: 44))
        
        let navItem = UINavigationItem(title: "Задачи")
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(makeTask))
        navItem.rightBarButtonItem = addItem
        
        let closeItem = UIBarButtonItem(title:"Выйти", style: .plain, target: nil, action: #selector(exitController))
        navItem.leftBarButtonItem = closeItem
        
        navBar.setItems([navItem], animated: false)
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        self.tableView = UITableView(frame: CGRect(x: 0, y: barHeight + 30, width: displayWidth, height: displayHeight - barHeight))
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 68
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        view.addSubview(navBar)
        self.calcNumberOfSections()
        self.makeDataGrouped()

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        
    }
    private func makeButton(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 273 , height: 76))
        button.center = CGPoint(x: self.view.center.x, y: 800)
        button.layer.cornerRadius = 5
        button.backgroundColor = .blue
        button.setTitle("Добавить новую задачу", for: .normal)
        button.addTarget(self, action: #selector(makeTask), for: .touchUpInside)

        self.view.addSubview(button)
    }
    @objc func refresh(_ sender: AnyObject) {
        self.loadData()
        refreshControl.endRefreshing()
    }
    var finished = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loaded = false
        self.finished = false
        self.getTasks()
        while (!self.finished) {
            
        }
        if(!self.loaded){
            self.makeLabel()
            self.makeButton()
            let navBar = UINavigationBar(frame: CGRect(x: 0, y: 50, width: view.frame.size.width, height: 44))
            
            let navItem = UINavigationItem(title: "Задачи")
            
            let closeItem = UIBarButtonItem(title:"Выйти", style: .plain, target: nil, action: #selector(exitController))
            navItem.leftBarButtonItem = closeItem
            
            navBar.setItems([navItem], animated: false)
            view.addSubview(navBar)
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("image.png")

                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }

            AF.download("https://loremflickr.com/320/240", to: destination).response { response in
                if response.error == nil, let imagePath = response.fileURL?.path {
                    var imageView : UIImageView
                    imageView  = UIImageView(frame:CGRect(x: 0, y: 0, width: 300, height: 300))
                    imageView.center = CGPoint(x: self.view.center.x, y: 400)
                    let image = UIImage(contentsOfFile: imagePath)
                    imageView.image = image
                    self.view.addSubview(imageView)
                    
                }
            }
        }
        else{
            self.makeTableView()
        }
    }
    override func viewDidLoad() {
        self.loaded = false
        super.viewDidLoad()

    }
    private func makeLabel(){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 48))
        label.center = CGPoint(x: self.view.center.x, y: 600)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Пока что у вас никаких дел. \n Хорошего отдыха!"
        self.view.addSubview(label)
    }
    private func deleteItem(item : Int){
        let headers = APIHandler.getHeaders()
        let url = URL(string: API.baseURL + "tasks" + "/" + String(item))!
        AF.request(url, method: .delete, headers: headers).validate().response { response in
                switch response.result{
                case .success:
                    print("success")
                case let .failure(error):
                    print(error)
                }
        }
    }
    private func loadData(){
        let string = API.baseURL + "tasks"
        let url = NSURL(string: string)
        let request = NSMutableURLRequest(url: url! as URL)
        request.setValue("Bearer " + APIHandler.getApiToken(), forHTTPHeaderField: "Authorization") //**
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        self.tasks = [RawServerResponse]()
        let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data
            {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if  let object = json as? [Any] {
                        for anItem in object as! [Dictionary<String, AnyObject>] {
                            print(anItem)
                            let task = RawServerResponse(id: anItem["id"] as! Int,
                                                         title: anItem["title"] as! String,
                                                         description: anItem["description"] as! String,
                                                         done: anItem["done"] as! Int,
                                                         deadline: anItem["deadline"] as! Int,
                                                         created: anItem["created"] as! Int,
                                                         category: RawServerResponse.CategoryResponseStructure(name: anItem["category"]?["name"] as! String ,
                                                                                                               id: anItem["category"]?["id"] as! Int ),
                                                         priority: RawServerResponse.PriorityResponseStructure(name: anItem["priority"]?["name"] as! String,
                                                                                                               id: anItem["priority"]?["id"] as! Int,
                                                                                                               color: anItem["priority"]?["color"] as! String))
                            self.tasks.append(task)
                            self.loaded = true
                            
                            DispatchQueue.main.async {
                                usleep(100000)
                                self.reload()
                            }
                        }
                        self.finished = true
                    }
                } catch {
                    print(error)
                }

            }
        }
        mData.resume()
    }
    private func reload(){
        if (self.loaded){
            self.calcNumberOfSections()
            self.makeDataGrouped()
            self.tableView.reloadData()
        }
    }
    private func getTasks() -> Bool{
        self.loadData()
        return true
    }
    @objc func makeTask() {
        let vc = storyboard?.instantiateViewController(identifier: "TableId1") as! InfoTableViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
}

extension MainViewController: TaskDelegate{
    func updateInfo(data: RawServerResponse) {
        return
    }
    
    func updateInfo() {
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        self.loaded = true
        self.makeTableView()
    }
}
