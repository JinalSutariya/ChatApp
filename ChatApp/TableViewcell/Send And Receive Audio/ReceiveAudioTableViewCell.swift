//
//  ReceiveAudioTableViewCell.swift
//  ChatApp
//
//  Created by CubezyTech on 09/07/24.
//

import UIKit

class ReceiveAudioTableViewCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timelbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
