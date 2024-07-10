//
//  ReceiveImageTableViewCell.swift
//  ChatApp
//
//  Created by CubezyTech on 08/07/24.
//

import UIKit

class ReceiveImageTableViewCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
