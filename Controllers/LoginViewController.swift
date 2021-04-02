//
//  ViewController.swift
//  NotForgot
//
//  Created by administrator on 31.03.2021.
//  Copyright © 2021 administrator. All rights reserved.
//

import UIKit
import Alamofire
class LoginViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
                let userDefaults = UserDefaults.standard
        do {
            let playingItMyWay = try userDefaults.getObject(forKey: "data", castTo: UserDataStruct.self)
            self.moveToMain()
        } catch {
            print(error.localizedDescription)
        }
    }
    private func moveToMain(){
        let vc = storyboard?.instantiateViewController(identifier: "MainId") as! MainViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    @IBAction func beginEditEmail(_ sender: Any) {
        self.emailField.text = ""
    }
    @IBAction func endEditEmail(_ sender: Any) {
        if (self.emailField.text == ""){
            self.emailField.text = "Поле не может быть пустым"
            self.emailField.textColor = .red
        }
    }
    @IBAction func editPasswordBegin(_ sender: Any) {
        self.passwordField.isSecureTextEntry = true
        self.passwordField.text = ""
    }
    
    @IBAction func editPasswordEnd(_ sender: Any) {
        if (self.passwordField.text == ""){
            self.passwordField.text = "Пароль не может быть пустым"
            self.passwordField.textColor = .red
            self.passwordField.isSecureTextEntry = false
        }
    }
    
    @IBAction func goToRegistration(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "RegisterId") as! RegisterViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    private func sendAuthLogin(email : String, password : String){
        let parameters = LoginRequest(email: email, password: password)

        //create the url with URL
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Accept": "application/json"
        ]
        let url = URL(string: API.baseURL + "login")!
        AF.request(url, method: .post,parameters: parameters, encoder: JSONParameterEncoder.default , headers: headers).validate().responseDecodable(of : LoginResponse.self) { response in
            print(response)
            switch response.result{
            case .success:
                self.save(email: email, name: "", api_token: response.value!.api_token, id: 0)
                self.moveToMain()
            case let .failure(error):
                print(error)
            }
            
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
    @IBAction func login(_ sender: Any) {
        if (self.emailField.text != "" && self.passwordField.text != ""){
            self.sendAuthLogin(email: self.emailField.text!, password: self.passwordField.text!)
        }
    }
}

