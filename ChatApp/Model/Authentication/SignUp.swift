//
//  SignUp.swift
//  ChatApp
//
//  Created by CubezyTech on 27/06/24.
//

import Foundation
struct SignUP: Codable {
    let success: String
    let message: String
    let data: DataClass
    let token: String
}

struct DataClass: Codable {
    let name: String
    let email: String
    let updatedAt: String
    let createdAt: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case name, email
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id
    }
}



