//
//  StatusAPICalling.swift
//  ChatApp
//
//  Created by CubezyTech on 02/07/24.
//

import Foundation

func updateStatus(to status: String) {
    let urlString = "https://fullchatapp.brijeshnavadiya.com/api/set/status/\(status)"
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET" // Using GET method
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let token = UserDefaults.standard.string(forKey: "token") {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    } else {
        print("No token found")
        return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error setting status: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Failed to set status: HTTP error")
            return
        }
        
        guard let data = data else {
            print("Failed to set status: No data")
            return
        }
        
        do {
            let statusResponse = try JSONDecoder().decode(OnlineStatusUpdateResponse.self, from: data)
            if statusResponse.success == "true" {
                print("\(status.capitalized) status set successfully")
            } else {
                print("Failed to set status: \(statusResponse.message)")
            }
        } catch {
            print("Failed to decode status update response: \(error.localizedDescription)")
        }
    }.resume()
}

func setOfflineStatus() {
    updateStatus(to: "offline")
}

func setOnlineStatus() {
    updateStatus(to: "online")
}
