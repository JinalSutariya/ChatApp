//
//  GroupBottomSheetVC.swift
//  ChatApp
//
//  Created by CubezyTech on 03/07/24.
//

import UIKit

protocol GroupCreationDelegate: AnyObject {
    func didCreateGroup()
}

class GroupBottomSheetVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
    // MARK: - OUTLET
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createBtn: UIButton!
    
    // MARK: - PROPERTY
    
    var users: [User] = []
    weak var delegate: GroupCreationDelegate?
    var selectedUsers: Set<IndexPath> = []
    let grabberView = UIView()
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBtn.layer.cornerRadius = 15
        tableView.delegate = self
        tableView.dataSource = self
        setOnlineStatus()
        tableView.reloadData()
        fetchUsers()
        
    }
    
    // MARK: - BUTTON CLICK
    
    @IBAction func backTap(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func saveTap(_ sender: Any) {
        showGroupNameAlert()
        
    }
    
    // MARK: - API CALL FOR CREATE GROUP
    
    func createGroup(groupName: String, memberIDs: [Int]) {
        guard let url = URL(string: "https://fullchatapp.brijeshnavadiya.com/api/create/group") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Retrieve authentication token
        let headerToken = UserDefaults.standard.string(forKey: "token") ?? ""
        request.addValue("Bearer \(headerToken)", forHTTPHeaderField: "Authorization")
        
        // Create request body as a JSON object
        let requestBody: [String: Any] = [
            "group_name": groupName,
            "members": memberIDs
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch {
            print("Error creating JSON data: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to create group:", error)
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Decode the JSON response
            do {
                let groupResponse = try JSONDecoder().decode(CreateGroup.self, from: data)
                print("Success: \(groupResponse.success), Message: \(groupResponse.message)")
                
                // Optionally, handle success or error messages
                if groupResponse.success == "true" {
                    print("Group created successfully!")
                    
                    DispatchQueue.main.async {
                        self.delegate?.didCreateGroup()
                        self.dismiss(animated: true)
                    }
                } else {
                    print("Failed to create group: \(groupResponse.message)")
                }
            } catch {
                print("Error decoding JSON response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // MARK: - API CALL FOR FETCH USER
    
    func fetchUsers() {
        GetAuthService.shared.getUserProfile { result in
            switch result {
            case .success(let userResponse):
                guard let userId = UserDefaults.standard.string(forKey: "userId"), let currentId = Int(userId) else {
                    print("User ID not found in UserDefaults.")
                    return
                }
                self.users = userResponse.data.filter { $0.id != currentId }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch users:", error)
            }
        }
    }
    
    // MARK: - ALL CUSTOM FUNCTION
    
    func showGroupNameAlert() {
        let alertController = UIAlertController(title: "Create Group", message: "Enter group name", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Group Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self,
                  let groupName = alertController.textFields?.first?.text,
                  !groupName.isEmpty else { return }
            
            // Extract selected user IDs
            let selectedUserIDs = self.selectedUsers.map { self.users[$0.row].id }
            
            self.createGroup(groupName: groupName, memberIDs: selectedUserIDs)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(createAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - TABLEVIEW DELEGATE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GroupTableViewCell
        let user = users[indexPath.row]
        cell.userName.text = user.name
        cell.isSelectedCell = selectedUsers.contains(indexPath)
        cell.selectBtn.tag = indexPath.row
        cell.selectBtn.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        cell.statusLbl.text = formatLastSeenDate(dateString: user.createdAt)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedUsers.contains(indexPath) {
            selectedUsers.remove(indexPath)
        } else {
            selectedUsers.insert(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func selectButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if selectedUsers.contains(indexPath) {
            selectedUsers.remove(indexPath)
        } else {
            selectedUsers.insert(indexPath)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}







