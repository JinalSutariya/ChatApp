//
//  GroupVC.swift
//  ChatApp
//
//  Created by CubezyTech on 03/07/24.
//

import UIKit

class GroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GroupCreationDelegate {
    
    // MARK: - OUTLET
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnView: UIView!
    
    // MARK: - PROPERTY
    
    var groups: [Group] = []
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        fetchGroups()
        btnView.layer.cornerRadius = 10
        tableView.reloadData()
        
    }
    
    // MARK: - BUTTON CLICK
    
    @IBAction func addGroupBtnTap(_ sender: Any) {
        
        let infoViewController = storyboard?.instantiateViewController(identifier: "groupBottomSheetVC") as? GroupBottomSheetVC
        infoViewController!.modalPresentationStyle = .overCurrentContext
        infoViewController!.modalTransitionStyle = .crossDissolve
        infoViewController!.delegate = self
        present(infoViewController!, animated: true)
        
    }
    // MARK: - ALL CUSTOM FUNCTION
    
    func didCreateGroup() {
        fetchGroups()
    }
    
    // MARK: - API CALL FOR FETCH GROUP
    
    func fetchGroups() {
        GetAuthService.shared.fetchgroups { result in
            switch result {
            case .success(let userResponse):
                self.groups = userResponse.data
                
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
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GetGroupTableViewcell
        cell.username.text = groups[indexPath.row].groupName
        cell.status.text = formatLastSeenDate(dateString: groups[indexPath.row].createdAt)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "groupChatVC") as! GroupChatVC
        
        chatVC.groupID = groups[indexPath.row].id
        chatVC.groupName = groups[indexPath.row].groupName
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}

