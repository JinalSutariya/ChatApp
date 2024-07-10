//
//  GetGroupMessage.swift
//  ChatApp
//
//  Created by CubezyTech on 03/07/24.
//

import Foundation

struct GroupSendMessageResponse: Codable {
    let success: String
    let message: String
    let data: GroupMessage
}

// MARK: - GroupMessageData
struct GroupMessage: Codable {
    let groupID: Int
    let senderID: Int
    let message: String
    let type: String
    let updatedAt: String
    let createdAt: String
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case senderID = "sender_id"
        case message, type
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id
    }
}
