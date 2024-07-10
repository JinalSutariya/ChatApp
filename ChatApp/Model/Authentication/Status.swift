//
//  Status.swift
//  ChatApp
//
//  Created by CubezyTech on 04/07/24.
//

import Foundation
struct OnlineStatusUpdateResponse: Codable {
    let success: String?
    let message: String
}
struct OfflineStatusUpdateResponse: Codable {
    let success: String?
    let message: String
}


struct StatusUpdate: Codable {
    let status: String
}
