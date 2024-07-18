//
//  Audio.swift
//  ChatApp
//
//  Created by CubezyTech on 09/07/24.
//

import AVFoundation
import UIKit

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    private var currentPlayingButton: UIButton?
    private var progressUpdateTimer: Timer?
    private var isPlaying = false
    private var currentPlaybackTime: TimeInterval = 0
    private weak var waveformProgressView: WaveformProgressView?
    
    private override init() {
        super.init()
    }
    
    // Play Audio
    @objc func playAudio(_ sender: UIButton, with message: String, waveformProgressView: WaveformProgressView) {
        guard let audioURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/audio/\(message)") else { return }
        
        if currentPlayingButton == sender {
            currentPlaybackTime = audioPlayer?.currentTime ?? 0
            audioPlayer?.pause()
            isPlaying = false
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            currentPlayingButton = nil
            progressUpdateTimer?.invalidate()
        } else {
            if let currentButton = currentPlayingButton {
                audioPlayer?.stop()
                currentButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
            downloadAndPlayAudio(from: audioURL, button: sender, waveformProgressView: waveformProgressView)
        }
    }
    
    // Download and Play Audio
    private func downloadAndPlayAudio(from url: URL, button: UIButton, waveformProgressView: WaveformProgressView) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            do {
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                self.isPlaying = true
                self.currentPlayingButton = button
                self.waveformProgressView = waveformProgressView
                DispatchQueue.main.async {
                    button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    self.startProgressUpdate()
                }
            } catch {
                print("Failed to play audio:", error)
            }
        }.resume()
    }
    
    private func startProgressUpdate() {
        progressUpdateTimer?.invalidate()
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func updateProgress() {
        guard let player = audioPlayer, let waveformProgressView = waveformProgressView else { return }
        let progress = CGFloat(player.currentTime / player.duration)
        waveformProgressView.progress = progress
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentPlayingButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
        progressUpdateTimer?.invalidate()
    }
}
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
