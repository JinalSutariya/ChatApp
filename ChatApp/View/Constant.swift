//
//  Constant.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import Foundation
import UIKit


// MARK: - BACK NAVIGATION

extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
// MARK: - TIME FORMATE

func formatTimestamp(_ timestamp: String) -> String? {
    let isoFormatter = DateFormatter()
    isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    guard let date = isoFormatter.date(from: timestamp) else {
        print("Failed to parse date")
        return nil
    }
    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat = "h:mm a"
    displayFormatter.timeZone = TimeZone.current
    
    return displayFormatter.string(from: date)
}

// MARK: - ROUND CORNERADIUS

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        self.layoutIfNeeded()
        
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.frame = self.bounds
        self.layer.mask = mask
    }
}

// MARK: - DATE FORMATE

func formatLastSeenDate(dateString: String) -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    inputFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MM/dd/yyyy, hh:mm a"
    
    if let date = inputFormatter.date(from: dateString) {
        let formattedDate = outputFormatter.string(from: date)
        return "Last Seen at \(formattedDate)"
    }
    return nil
}

