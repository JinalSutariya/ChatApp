//
//  ProgressView.swift
//  ChatApp
//
//  Created by CubezyTech on 22/07/24.
//

import Foundation
import UIKit

class WaveformProgressView: UIView {
    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let width = rect.width
        let height = rect.height
        
        // Calculate the point where the progress ends
        let progressX = width * progress
        
        // Draw the waveform bars
        let numberOfBars = 30
        let barWidth: CGFloat = width / CGFloat(numberOfBars)
        let maxHeight: CGFloat = height
        
        for i in 0..<numberOfBars {
            let x = CGFloat(i) * barWidth
            let randomHeight = CGFloat(arc4random_uniform(UInt32(maxHeight)))
            let barHeight = max(randomHeight, maxHeight * 0.3) // Ensure a minimum height
            let y = height - barHeight
            
            let barColor = x <= progressX ? UIColor.systemBlue.cgColor : UIColor.systemGray3.cgColor
            context.setFillColor(barColor)
            
            let barPath = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth * 0.8, height: barHeight), cornerRadius: barWidth * 0.4)
            context.addPath(barPath.cgPath)
            context.fillPath()
        }
    }
}

