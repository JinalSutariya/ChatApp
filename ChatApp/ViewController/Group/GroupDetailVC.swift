//
//  GroupDetailVC.swift
//  ChatApp
//
//  Created by CubezyTech on 10/07/24.
//

import UIKit

class GroupDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var groupID: Int?
    var groupData: GroupData?
    var currentUserID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserID = UserDefaults.standard.integer(forKey: "userId")
        
        
        tableView.delegate = self
        tableView.dataSource = self
        fetchGroupDetail(groupId: groupID!)
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
    }
    
    @IBAction func backTap(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    func fetchGroupDetail(groupId: Int) {
        GetAuthService.shared.fetchGroupDetails(groupID: groupId) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.groupData = response.data 
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch group details:", error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupData?.groupmember.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserListTableViewCell
     

        if let member = groupData?.groupmember[indexPath.row] {
            cell.userNameLbl.text = member.userDetail.name
            
            if member.userId == currentUserID {
                cell.userNameLbl.text = "You" 
            } else {
                cell.userNameLbl.textColor = UIColor.black
            }
            
            cell.timeLbl.text = formatLastSeenDate(dateString: member.userDetail.createdAt)
        }
        
        return cell
    }
}

