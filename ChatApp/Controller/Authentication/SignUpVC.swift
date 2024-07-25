//
//  SignUpVC.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import UIKit

class SignUpVC: UIViewController {
    
    // MARK: - OUTLET
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var pwdTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var userNameTxt: UITextField!
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.height/2
    }
    
    // MARK: - BUTTON CLICK
    
    @IBAction func signUpTap(_ sender: Any) {
        guard let name = userNameTxt.text, let email = emailTxt.text, let password = pwdTxt.text else {
            return
        }
        // MARK: - API CALL FOR SIGNUP
        
        PostAuthService.shared.signup(name: name, email: email, password: password) { [weak self] result in
            switch result {
            case .success(let signUpResponse):
                DispatchQueue.main.async {
                    print("Sign up successful! Token: \(signUpResponse.token), User ID: \(signUpResponse.data.id)")
                    UserDefaults.standard.set(signUpResponse.token, forKey: "token")
                    UserDefaults.standard.synchronize()
                    UserDefaults.standard.set(signUpResponse.data.id, forKey: "userId")
                    
                    if let userListVC = self?.storyboard?.instantiateViewController(withIdentifier: "userListVC") as? UserListVC {
                        self?.navigationController?.pushViewController(userListVC, animated: true)
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
        
    }
}

