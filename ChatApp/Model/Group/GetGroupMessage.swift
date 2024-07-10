//
//  GetGroupmessage.swift
//  ChatApp
//
//  Created by CubezyTech on 03/07/24.
//

import Foundation




// Model for the response from the server
struct GetGroupMessagesResponse: Codable {
    let success: String
    let message: String
    let data: GetGroupMessagesData
}
// Model for the paginated data including messages and pagination metadata
struct GetGroupMessagesData: Codable {
    let currentPage: Int
    let data: [GetGroupMessage]
    let firstPageURL: String
    let from: Int
    let lastPage: Int
    let lastPageURL: String
    let links: [Link]
    let nextPageURL: String?
    let path: String
    let perPage: Int
    let prevPageURL: String?
    let to: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case links
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to
        case total
    }
}



// Model for individual message data
struct GetGroupMessage: Codable {
    let id: Int
    let groupId: Int
    let senderId: Int
    let message: String
    let type: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case senderId = "sender_id"
        case message
        case type
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
// Model for individual link data
struct Link: Codable {
    let url: String?
    let label: String
    let active: Bool
}
