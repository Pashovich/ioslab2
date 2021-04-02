//
//  RegisterViewController.swift
//  NotForgot
//
//  Created by administrator on 31.03.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
struct Data : Encodable {
    let email: String
    let password: String
    let name : String
}
class RegisterViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    var defaultEmailText: String!
    
    @IBAction func goBackToLogin(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultEmailText = "Почтовый ящик"
    }
    
    @IBAction func beginEditName(_ sender: Any) {
        self.nameField.text = ""
        self.nameField.textColor = .black
    }
    
    @IBAction func endEditName(_ sender: Any) {
        if (self.nameField.text == ""){
            self.nameField.text = "Введите имя"
            self.nameField.textColor = .red
        }
    }
    @IBAction func beginEditEmail(_ sender: Any) {
        if (self.emailField.text == self.defaultEmailText){
                self.emailField.text = ""
        }
        
        self.emailField.textColor = .black
    }
    
    @IBAction func endEditEmail(_ sender: Any) {
        if (self.emailField.text == ""){
            self.emailField.text = "Введите почту"
            self.emailField.textColor = .red
        }
    }
    @IBAction func beginEditPassword(_ sender: Any) {
        self.passwordField.isSecureTextEntry = true
        self.passwordField.text = ""
        self.passwordField.textColor = .black
    }
    
    @IBAction func endEditPassword(_ sender: Any) {
        if (self.passwordField.text == ""){
            self.passwordField.text = "Введите пароль"
            self.passwordField.textColor = .red
            self.passwordField.isSecureTextEntry = false
        }
    }
    @IBAction func beginEditConfirmPassword(_ sender: Any) {
        self.confirmPasswordField.isSecureTextEntry = true
        self.confirmPasswordField.text = ""
        self.confirmPasswordField.textColor = .black
    }
    @IBAction func endEditConfirmPassword(_ sender: Any) {
        if (self.confirmPasswordField.text != self.passwordField.text){
            self.confirmPasswordField.text = "Пароли не совпадают"
            self.confirmPasswordField.textColor = .red
            self.confirmPasswordField.isSecureTextEntry = false
        }
        
    }
    private func save(email : String, name : String, api_token : String, id : Int){
        let playingItMyWay = UserDataStruct(email: email, id: id, name: name, api_token: api_token)
        let userDefaults = UserDefaults.standard
        do {
            try userDefaults.setObject(playingItMyWay, forKey: "data")
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func sendRegisterPost(){
        let parameters = Data(email: self.emailField.text!, password: self.passwordField.text!, name : self.nameField.text!)


        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Accept": "application/json"
        ]
        let url = URL(string: API.baseURL + "register")!
        AF.request(url, method: .post,parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers).validate().responseDecodable(of : RegisterResonse.self) { response in
            switch response.result{
            case .success:
                self.save(email: response.value!.email, name: response.value!.name, api_token: response.value!.api_token, id: response.value!.id)
                self.login()
            case let .failure(error):
                print(error)
            }
        }
    }
    @IBAction func register(_ sender: Any) {
        if (
            self.nameField.text != "" &&
                self.emailField.text != "" &&
            self.passwordField.text != "" &&
                self.passwordField.text == self.confirmPasswordField.text
            ){
            self.sendRegisterPost()
        }
    }
    private func login() {
        let vc = storyboard?.instantiateViewController(identifier: "LoginId") as! LoginViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
