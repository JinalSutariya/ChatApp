//
//  ReceiveMessageTableViewCell.swift
//  ChatApp
//
//  Created by CubezyTech on 08/07/24.
//

import UIKit

class ReceiveMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var msgLbl: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
