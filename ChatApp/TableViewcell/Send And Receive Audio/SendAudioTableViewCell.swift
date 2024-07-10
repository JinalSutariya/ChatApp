//
//  SendAudioTableViewCell.swift
//  ChatApp
//
//  Created by CubezyTech on 08/07/24.
//

import UIKit

class SendAudioTableViewCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
}
