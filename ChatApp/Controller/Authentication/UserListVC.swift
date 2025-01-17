//
//  UserListVC.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import UIKit

class UserListVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    // MARK: - OUTLET
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTY
    
    var users: [User] = []
    var currentId: Int?
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentId = UserDefaults.standard.integer(forKey: "userId")
        
        tableView.delegate = self
        tableView.dataSource = self
        setOnlineStatus()
        tableView.reloadData()
        fetchUsers()
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        
        
    }
    // MARK: - BUTTON CLICK
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        
        setOfflineStatus()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            exit(0)
        }
    }
    
    // MARK: - API CALL FOR FETCH USERLIST
    
    func fetchUsers() {
        GetAuthService.shared.getUserProfile { result in
            switch result {
            case .success(let userResponse):
                if let currentId = self.currentId {
                    self.users = userResponse.data.filter { $0.id != currentId }
                } else {
                    self.users = userResponse.data
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch users:", error)
            }
        }
    }
    // MARK: - TABLEVIEW DELEGATE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserListTableViewCell
        cell.userNameLbl.text = users[indexPath.row].name
        cell.timeLbl.text = formatLastSeenDate(dateString: users[indexPath.row].createdAt)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatVC
        chatVC.name = users[indexPath.row].name
        chatVC.status = users[indexPath.row].status
        
        chatVC.receiverID = String(users[indexPath.row].id)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
