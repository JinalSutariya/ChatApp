//
//  GetAllChatData.swift
//  ChatApp
//
//  Created by CubezyTech on 28/06/24.
//

import Foundation

struct ChatMessagesResponse: Codable {
    let success: String
    let message: String
    let data: ChatData
}

struct ChatData: Codable {
    let currentPage: Int
    let messages: [Message]
    let firstPageURL: String
    let from, lastPage, perPage, to, total: Int
    let lastPageURL, nextPageURL, path, prevPageURL: String?
    let links: [PageLink]

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case messages = "data"
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to, total
        case links
    }
}

struct Message: Codable {
    let id, converID, senderID, receiverID: Int
    let message, type, createdAt, updatedAt: String

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

struct PageLink: Codable {
    let url: String?
    let label: String
    let active: Bool
}


