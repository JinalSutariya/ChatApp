//
//  AllUser.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import Foundation


struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let status: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, email, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserResponse: Codable {
    let success: String
    let message: String
    let data: [User]
}
