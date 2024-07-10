//
//  Constant.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import Foundation
import UIKit


// Return Back

extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
 // Time Formate

func formatTimestamp(_ timestamp: String) -> String? {
    // Create a date formatter for the incoming timestamp
    let isoFormatter = DateFormatter()
    isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Handle time zone if needed

    // Convert the timestamp string to a Date object
    guard let date = isoFormatter.date(from: timestamp) else {
        print("Failed to parse date")
        return nil
    }

    // Create a date formatter for the desired output format
    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat = "h:mm a" // Desired format: 10:00 PM
    displayFormatter.timeZone = TimeZone.current // Use the current time zone

    // Convert the Date object to a formatted string
    return displayFormatter.string(from: date)
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        self.layoutIfNeeded() // Ensure the view's layout is up-to-date
        
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.frame = self.bounds // Ensure the mask frame matches the view's bounds
        self.layer.mask = mask
    }
}
func formatLastSeenDate(dateString: String) -> String? {
    // Define the input date formatter to parse the ISO8601 date string
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    inputFormatter.timeZone = TimeZone(abbreviation: "UTC") // Set timezone to UTC for ISO8601 strings

    // Define the output date formatter to convert the date to the desired format
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MM/dd/yyyy, hh:mm a"
    
    // Convert the date string to Date object
    if let date = inputFormatter.date(from: dateString) {
        // Convert the Date object to formatted string
        let formattedDate = outputFormatter.string(from: date)
        return "Last Seen at \(formattedDate)"
    }
    
    // Return nil if date conversion fails
    return nil
}

