//
//  LoginVC.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - OUTLET
    
    @IBOutlet weak var pwdTxt: UITextField!
    @IBOutlet weak var mailTxt: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailTxt.returnKeyType = .done
        mailTxt.delegate = self
        pwdTxt.returnKeyType = .done
        pwdTxt.delegate = self
        
        loginBtn.layer.cornerRadius = loginBtn.frame.size.height/2
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.height/2
        mailTxt.text = "jinall@gmail.com"
        pwdTxt.text = "123456"
    }
    
    // MARK: - BUTTON CLICK
    
    @IBAction func loginTap(_ sender: Any) {
        guard let email = mailTxt.text, let password = pwdTxt.text else {
            return
        }
        PostAuthService.shared.login(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let loginResponse):
                DispatchQueue.main.async {
                    print("Login successful! Token: \(loginResponse.token), User ID: \(loginResponse.data.id)")
                    UserDefaults.standard.set(loginResponse.token, forKey: "token")
                    UserDefaults.standard.synchronize()
                    UserDefaults.standard.set(loginResponse.data.id, forKey: "userId")
                    
                    if let tabBarVC = self?.storyboard?.instantiateViewController(withIdentifier: "tabBar") as? TabViewViewController {
                        if let secondVC = tabBarVC.viewControllers?[0] as? UserListVC {
                            secondVC.currentId = loginResponse.data.id
                        }
                        self?.navigationController?.pushViewController(tabBarVC, animated: true)
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func signUpTap(_ sender: Any) {
        let signUp = self.storyboard?.instantiateViewController(withIdentifier: "signUpVC") as! SignUpVC
        self.navigationController?.pushViewController(signUp, animated: true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("Done button pressed")
        return true
    }
}

