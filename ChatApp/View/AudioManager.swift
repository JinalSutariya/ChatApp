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
    
    private override init() {
        super.init()
    }
    
    
    // Play Audio
    
    @objc func playAudio(_ sender: UIButton, with message: String) {
        guard let audioURL = URL(string: "https://fullchatapp.brijeshnavadiya.com/public/assets/audio/\(message)") else { return }
        
        if currentPlayingButton == sender {
            currentPlaybackTime = audioPlayer?.currentTime ?? 0
            audioPlayer?.pause()
            isPlaying = false
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            currentPlayingButton = nil
        } else {
            if let currentButton = currentPlayingButton {
                audioPlayer?.stop()
                currentButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
            downloadAndPlayAudio(from: audioURL, button: sender)
        }
    }
    
    
    // Download Audio
    
    
    private func downloadAndPlayAudio(from url: URL, button: UIButton) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            do {
                self.audioPlayer = try AVAudioPlayer(data: data)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                self.isPlaying = true
                self.currentPlayingButton = button
                DispatchQueue.main.async {
                    button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                }
            } catch {
                print("Failed to play audio:", error)
            }
        }.resume()
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentPlayingButton?.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
}




