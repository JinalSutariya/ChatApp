//
//  Login.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import Foundation
struct Login: Codable {
    let success: String
    let message: String
    let data: DataClasss
    let token: String
}

struct DataClasss: Codable {
    let id: Int
    let name, email, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


