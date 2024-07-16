//
//  UserListVC.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import UIKit

class UserListVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    var users: [User] = []
    var currentId: Int?

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
    
    @IBAction func logoutTapped(_ sender: UIButton) {
          
        setOfflineStatus()
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              exit(0)
          }
       }
    
    
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
class WavedProgressView: UIProgressView {

    var lineMargin:CGFloat = 2.0
    var volumes:[CGFloat] = [0.5,0.3,0.2,0.6,0.4,0.5,0.8,0.6,0.4]

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.darkGray
    }

    override var frame: CGRect {
        didSet{
            self.drawVerticalLines()
        }
    }

    var lineWidth:CGFloat = 3.0{
        didSet{
            self.drawVerticalLines()
        }
    }

    func drawVerticalLines() {
        let linePath = CGMutablePath()
        for i in 0..<self.volumes.count {
            let height = self.frame.height * volumes[i]
            let y = (self.frame.height - height) / 2.0
            linePath.addRect(CGRect(x: lineMargin + (lineMargin + lineWidth) * CGFloat(i), y: y, width: lineWidth, height: height))
        }

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.fillColor = UIColor.white.cgColor
        self.layer.sublayers?.removeAll()
        self.layer.addSublayer(lineLayer)
    }
}
