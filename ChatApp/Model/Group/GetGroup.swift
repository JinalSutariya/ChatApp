//
//  GetGroup.swift
//  ChatApp
//
//  Created by CubezyTech on 03/07/24.
//

import Foundation

struct Group: Codable {
    let id: Int
    let groupName: String
    let groupCreateUserId: Int
    let createdAt: String
    let updatedAt: String
    
    // Coding keys to map JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case groupName = "group_name"
        case groupCreateUserId = "group_create_user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// Model for the response from the server
struct GetGroupsResponse: Codable {
    let success: String
    let message: String
    let data: [Group]
    
    // Coding keys to map JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
}

