//
//  InfoTableViewController.swift
//  NotForgot
//
//  Created by administrator on 01.04.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import UIKit
import Alamofire
class InfoTableViewController: UITableViewController,UITextViewDelegate {
    @IBOutlet weak var datePickerTextField: UITextField!
    private var datePicker : UIDatePicker!
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var DescriptionTextView: UITextView!
    
    @IBOutlet weak var priorityLabelText: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryLabelText: UILabel!
    @IBOutlet weak var categoryCell: UITableViewCell!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var labelDatePicker: UILabel!
    
    var delegate : TaskDelegate?
    var categoryStruct : CategoryStruct!
    var priorityStruct : PriorityStruct!
    
    var titleDefaultText = "Заголовок"
    var descriptionDefaultText = "Описание"
    var defaultTextChoose = "Не выбрано"
    var data : RawServerResponse!
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text != self.titleDefaultText || textView.text != self.descriptionDefaultText){
            textView.textColor = .black
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.DescriptionTextView.delegate = self
        self.titleTextView.delegate = self
        
        self.categoryCell.accessoryType = .disclosureIndicator
        self.dateCell.accessoryType = .disclosureIndicator
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(InfoTableViewController.dateChanged(datePicker:)), for: .valueChanged)
        self.datePickerTextField.inputView = datePicker
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        let addItem : UIBarButtonItem!
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)
        let navItem = UINavigationItem(title: "Новая задача")
        if (self.data != nil){
            self.updateData()
            addItem = UIBarButtonItem(title:"Сохранить", style: .plain, target: nil, action: #selector(patchTask))
            navItem.rightBarButtonItem = addItem
            let closeItem = UIBarButtonItem(title:"Закрыть", style: .plain, target: nil, action: #selector(closeWithoutData))
            navItem.leftBarButtonItem = closeItem
        }
        else{
            addItem = UIBarButtonItem(title:"Сохранить", style: .plain, target: nil, action: #selector(saveTask))
            navItem.rightBarButtonItem = addItem
            let closeItem = UIBarButtonItem(title:"Закрыть", style: .plain, target: nil, action: #selector(closeWithoutData))
            navItem.leftBarButtonItem = closeItem
        }


        

        navBar.setItems([navItem], animated: false)
    }
    private func updateData(){
        let timeStamp = Date(timeIntervalSince1970: TimeInterval(data.deadline))
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "dd.MM.yyyy"
        self.datePickerTextField.text = formatter3.string(from: timeStamp)
        self.dateCell.accessoryType = .none
        self.datePicker.date = timeStamp
        self.categoryLabelText.text = self.data.category.name
        self.DescriptionTextView.text = self.data.description
        self.priorityLabelText.text = self.data.priority.name
        self.titleTextView.text = self.data.title
        self.categoryStruct = CategoryStruct(name: self.data.category.name, id: self.data.category.id)
        self.priorityStruct = PriorityStruct(name: self.data.priority.name, color: self.data.priority.color, id: self.data.priority.id)
        
    }
    @objc func closeWithoutData(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func close(){
        self.delegate?.updateInfo(data: self.data)
        self.dismiss(animated: true, completion: nil)
    }
    private func sendSave(){
        let timeStamp = Int((self.datePicker?.date.timeIntervalSince1970)!)
        let parameters = SaveTask(title: self.titleTextView.text, description: self.DescriptionTextView.text, done: 1, deadline: timeStamp, category_id: self.categoryStruct.id, priority_id: self.priorityStruct.id)
        let headers = APIHandler.getHeaders()
        
        
        let url = URL(string: API.baseURL + "tasks")!
        AF.request(url, method: .post,parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers).validate().responseDecodable(of :RawServerResponse.self ) { response in
            switch response.result{
            case .success:
                print(response)
            case let .failure(error):
                print(error)
            }
            self.dismiss(animated: true, completion: nil)
        }
        self.delegate?.updateInfo()
        
        
    }
    @objc func patchTask(){
        let timeStamp = Int((self.datePicker?.date.timeIntervalSince1970)!)
        let parameters = SaveTask(title: self.titleTextView.text, description: self.DescriptionTextView.text, done: 1, deadline: timeStamp, category_id: self.categoryStruct.id, priority_id: self.priorityStruct.id)
        let headers = APIHandler.getHeaders()
        
        
        let url = URL(string: API.baseURL + "tasks" + "/" + String(self.data.id))!
        AF.request(url, method: .patch,parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers).validate().responseDecodable(of :SaveTask.self ) { response in
            switch response.result{
            case .success:
                print(response.result)
            case let .failure(error):
                print(error)
            }
            self.data.title = self.titleTextView.text
            self.data.description = self.DescriptionTextView.text
            self.data.deadline = timeStamp
            self.data.category.name = self.categoryStruct.name
            self.data.priority.name = self.priorityStruct.name
            self.data.priority.color = self.priorityStruct.color
            self.data.priority.id = self.priorityStruct.id
            self.data.category.id = self.categoryStruct.id
            self.delegate?.updateInfo(data: self.data)
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func saveTask(){
        if(
            self.categoryStruct != nil &&
            self.priorityStruct != nil &&
            (self.DescriptionTextView.text != self.descriptionDefaultText) &&
            (self.titleTextView.text != self.titleDefaultText) &&
            (self.datePickerTextField.text != self.defaultTextChoose)
            ){
            self.sendSave()
        }
    }

    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
    func presentPriorityController(){
        let vc = storyboard?.instantiateViewController(identifier: "ProiritiesId") as! PrioritiesViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    func presentCategoryController(){
        let vc = storyboard?.instantiateViewController(identifier: "CategoroiesId") as! CategoriesViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            self.presentCategoryController()
            self.tableView.deselectRow(at: indexPath, animated: true)
        case 0:
            self.presentPriorityController()
            self.tableView.deselectRow(at: indexPath, animated: true)
        default:
            self.datePicker.endEditing(true)
        }

        
    }

    @objc func dateChanged(datePicker : UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        self.datePickerTextField.text = dateFormatter.string(from: datePicker.date)
        self.dateCell.accessoryType = .none
    }
    public func updateCategotyLabel(labelName : String){
        self.categoryLabel.text = labelName
    }

}
extension InfoTableViewController : SelectedCategoryDelegate, ProDelegate {
    func selectPriority(priority: PriorityStruct) {
                self.dismiss(animated: true, completion: nil)
        self.priorityLabelText.text = priority.name
        self.priorityStruct = priority
    }
    
    func selectCategory(category: CategoryStruct) {
        self.dismiss(animated: true, completion: nil)
        self.categoryLabelText.text = category.name
        self.categoryStruct = category
    }


}


