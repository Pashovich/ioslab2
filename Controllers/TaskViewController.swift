//
//  TaskViewController.swift
//  NotForgot
//
//  Created by administrator on 02.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    var data : RawServerResponse!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var priorityText: UILabel!
    @IBOutlet weak var priorityColor: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 40, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)
        let navItem = UINavigationItem(title: "Задача")
        let editItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(updateTask))
        navItem.rightBarButtonItem = editItem
        
        let backItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(goBack))
        navItem.leftBarButtonItem = backItem
        navBar.setItems([navItem], animated: false)
        self.titleLabel.text = data.title
        self.descriptionText.text = data.description
        self.categoryLabel.text = data.category.name
        self.priorityText.text = data.priority.name
        self.priorityColor.backgroundColor = UIColor(hexString: data.priority.color)
        
        let timeStamp = Date(timeIntervalSince1970: TimeInterval(data.deadline))
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "dd.MM.yyyy"
        self.dateText.text = "До " + formatter3.string(from: timeStamp)
        
        
    }
    
    @objc func updateTask(){
        let vc = storyboard?.instantiateViewController(identifier: "TableId1") as! InfoTableViewController
        vc.delegate = self
        vc.data = self.data
            present(vc, animated: true, completion: nil)
        }
    

}
extension TaskViewController: TaskDelegate{
    func updateInfo() {
        return
    }
    
    func updateInfo(data: RawServerResponse) {
        self.titleLabel.text = data.title
        self.descriptionText.text = data.description
        self.categoryLabel.text = data.category.name
        self.priorityText.text = data.priority.name
        self.priorityColor.backgroundColor = UIColor(hexString: data.priority.color)
        
        let timeStamp = Date(timeIntervalSince1970: TimeInterval(data.deadline))
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "dd.MM.yyyy"
        self.dateText.text = "До " + formatter3.string(from: timeStamp)
    }
}
