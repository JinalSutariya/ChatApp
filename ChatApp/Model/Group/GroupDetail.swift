//
//  GroupDetail.swift
//  ChatApp
//
//  Created by CubezyTech on 10/07/24.
//

import Foundation
// MARK: - GroupDetailsResponse
struct GroupDetailsResponse: Codable {
    let success: String
    let message: String
    let data: GroupData
}

// MARK: - GroupData
struct GroupData: Codable {
    let id: Int
    let groupName: String
    let groupCreateUserId: Int
    let createdAt: String
    let updatedAt: String
    let groupmember: [GroupMember]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case groupName = "group_name"
        case groupCreateUserId = "group_create_user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case groupmember
    }
}

// MARK: - GroupMember
struct GroupMember: Codable {
    let id: Int
    let groupId: Int
    let userId: Int
    let createdAt: String
    let updatedAt: String
    let userDetail: UserDetail
    
    private enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userDetail = "userdetail"
    }
}

// MARK: - UserDetail
struct UserDetail: Codable {
    let id: Int
    let name: String
    let email: String
    let status: String
    let createdAt: String
    let updatedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
