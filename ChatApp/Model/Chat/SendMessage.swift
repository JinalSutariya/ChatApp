//
//  SendMessage.swift
//  ChatApp
//
//  Created by CubezyTech on 28/06/24.
//

import Foundation
// Root response model
struct SendMessageResponse: Codable {
    let success: String
    let message: String
    let data: MessageData
}

// Data model for the message
struct MessageData: Codable {
    let converID: Int
    let senderID: Int
    let receiverID: Int
    let message: String
    let type: String
    let updatedAt: String
    let createdAt: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case converID = "conver_id"
        case senderID = "sender_id"
        case receiverID = "receiver_id"
        case message
        case type
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id
    }
}










struct Messages: Codable {
    let id, converID, senderID : Int
    let message, type, createdAt, receiverID, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case converID = "conver_id"
        case senderID = "sender_id"
        case receiverID = "receiver_id"
        case message, type
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
