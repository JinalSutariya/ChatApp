//
//  GetApiManager.swift
//  ChatApp
//
//  Created by CubezyTech on 09/07/24.
//

import Foundation
class GetAuthService {
    
    static let shared = GetAuthService()
    
    private init() {}
    
    
    func GetRequest<T: Decodable>(endpoint: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let urlString = "\(Constant.API.BASE_URL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "No token found", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let errorMessage = "Error: Status code \(statusCode)"
                completion(.failure(NSError(domain: errorMessage, code: statusCode, userInfo: nil)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    
    
    func getUserProfile(completion: @escaping (Result<UserResponse, Error>) -> Void) {
        GetRequest(endpoint: "api/all/users", responseType: UserResponse.self, completion: completion)
    }
    func getAllChat(page: Int, chatID: String, completion: @escaping (Result<ChatMessagesResponse, Error>) -> Void) {
        GetRequest(endpoint: "api/get/full/chat/messages?page=\(page)&chat_user_id=\(chatID)", responseType: ChatMessagesResponse.self, completion: completion)
    }
    
    func fetchgroups(completion: @escaping (Result<GetGroupsResponse, Error>) -> Void) {
        GetRequest(endpoint: "api/get/groups", responseType: GetGroupsResponse.self, completion: completion)
    }
    func groupGetChat(page: Int, chatID: Int, completion: @escaping (Result<GetGroupMessagesResponse, Error>) -> Void) {
        GetRequest(endpoint: "api/get/group/chat?group_id=\(chatID)&page=\(page)", responseType: GetGroupMessagesResponse.self, completion: completion)
    }
    
    func fetchGroupDetails(groupID: Int, completion: @escaping (Result<GroupDetailsResponse, Error>) -> Void) {
        GetRequest(endpoint: "api/get/group/details?group_id=\(groupID)", responseType: GroupDetailsResponse.self, completion: completion)
    }
}
