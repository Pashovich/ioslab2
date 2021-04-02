//
//  CategoriesTableViewController.swift
//  NotForgot
//
//  Created by administrator on 01.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import UIKit
import Alamofire


struct CatrgoryData: Encodable {
    let name : String
}
struct Categories: Codable {
    let name: String
    let id: Int
    
    func getString() {
        print( "Name: \(name), Id: \(id)" )
    }
}

class CategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate : SelectedCategoryDelegate?
    @IBOutlet weak var navigationBar: UINavigationItem!
    var api_token : String!
    var done = false
    var categories : [CategoryStruct]!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let a = self.categories[indexPath.row]
        self.delegate?.selectCategory(category:  a)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.categories == nil{
            return 0
        }
        return self.categories.count
    }

    private func saveCategory(name : String){
        let parameters = CatrgoryData(name: name)
        let headers = APIHandler.getHeaders()
        let url = URL(string: API.baseURL + "categories")!
        
        AF.request(url, method: .post,parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers).validate().responseDecodable(of : CategoryPost.self) { response in
            switch response.result{
            case .success:
                print(response)
            case let .failure(error):
                print(error)
            }
        }
        
    }
    @objc func addCategory() {
        let alertController = UIAlertController(title: "Добавьте категорию задач", message: "Название должно кратко отражать суть категории", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let categoryNameTextfield = alertController.textFields![0] as UITextField
            if (categoryNameTextfield.text! != ""){
                    self.saveCategory(name: categoryNameTextfield.text!)
            }

        })
        let cancelButton = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)

        alertController.addAction(cancelButton)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = self.categories[indexPath.row].name
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
        tableView.delegate = self
        tableView.dataSource = self
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem(title: "Категория")
        let doneItem = UIBarButtonItem(title: "Закрыть",style: .plain, target: nil, action: #selector(handleClosure))
        navItem.leftBarButtonItem = doneItem

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategory))
        navItem.rightBarButtonItem = addItem
        navBar.setItems([navItem], animated: false)
    }
    @objc func handleClosure(){
        self.dismiss(animated: true, completion: nil)
    }
    private func loadCategories(){
        let string = API.baseURL + "categories"
        let url = NSURL(string: string)
        let request = NSMutableURLRequest(url: url! as URL)
        request.setValue("Bearer " + APIHandler.getApiToken(), forHTTPHeaderField: "Authorization") //**
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        self.categories = [CategoryStruct]()
        let mData = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let data = data
            {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if  let object = json as? [Any] {
                        for anItem in object as! [Dictionary<String, AnyObject>] {
                            let categoryName = anItem["name"] as! String
                            let categoryID = anItem["id"] as! Int
                            let categoryStruct = CategoryStruct(name: categoryName, id: categoryID)
                            self.categories.append(categoryStruct)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                } catch {
                    print(error)
                }
                
            }
        }
        mData.resume()
    }

}
