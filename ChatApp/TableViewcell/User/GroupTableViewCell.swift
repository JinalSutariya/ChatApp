//
//  GroupTableViewCell.swift
//  ChatApp
//
//  Created by CubezyTech on 03/07/24.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    
    
      var isSelectedCell: Bool = false {
          didSet {
              updateButtonImage()
          }
      }
      
      override func awakeFromNib() {
          super.awakeFromNib()
          // Initialization code
      }

      override func setSelected(_ selected: Bool, animated: Bool) {
          super.setSelected(selected, animated: animated)
          // Configure the view for the selected state
      }
      
      private func updateButtonImage() {
          let imageName = isSelectedCell ? "checkmark.square.fill" : "square"
          selectBtn.setImage(UIImage(systemName: imageName), for: .normal)
      }
  }


class GetGroupTableViewcell: UITableViewCell{
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
