//
//  PostAPIManager.swift
//  ChatApp
//
//  Created by CubezyTech on 09/07/24.
//

import Foundation
class PostAuthService {
    
    static let shared = PostAuthService()
    
    private init() {}
    
    func PostRequest<T: Decodable>(endpoint: String, requestBody: [String: Any], responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let urlString = "\(Constant.API.BASE_URL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No token found")
            return
        }
        
        let headerToken = getUSERTOKEN()
        request.addValue(headerToken, forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                let errorMessage = "No data received"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            if httpResponse.statusCode != 200 {
                // Log detailed response for debugging
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to parse response data"
                print("Error response: \(responseString)")
                
                let errorMessage = "Error: Status code \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            do {
                let responseObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(responseObject))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    
    
    
    func login(email: String, password: String, completion: @escaping (Result<Login, Error>) -> Void) {
        let requestBody: [String: Any] = ["email": email, "password": password]
        PostRequest(endpoint: "api/login/user", requestBody: requestBody, responseType: Login.self, completion: completion)
    }
    
    func signup(name: String, email: String, password: String, completion: @escaping (Result<SignUP, Error>) -> Void) {
        let requestBody: [String: Any] = ["name": name, "email": email, "password": password]
        PostRequest(endpoint: "api/register/user", requestBody: requestBody, responseType: SignUP.self, completion: completion)
    }
    
    func sendMessage(message: String, receiverID: String, completion: @escaping (Result<SendMessageResponse, Error>) -> Void) {
        let requestBody: [String: Any] = ["receiveruser_id": receiverID, "message": message, "type": "text"]
        PostRequest(endpoint: "api/send/message", requestBody: requestBody, responseType: SendMessageResponse.self, completion: completion)
    }
    
  

    
    func createGroup(groupName: String, memberIDs: [Int], completion: @escaping (Result<CreateGroup, Error>) -> Void) {
        let requestBody: [String: Any] = [
            "group_name": groupName,
            "members": memberIDs
        ]
        PostRequest(endpoint: "api/create/group", requestBody: requestBody, responseType: CreateGroup.self, completion: completion)
    }
    
    func groupSendMessage(message: String, groupId: Int, completion: @escaping (Result<GroupSendMessageResponse, Error>) -> Void) {
        let requestBody: [String: Any] = ["group_id": groupId, "message": message, "type": "text"]
        PostRequest(endpoint: "api/send/group/message", requestBody: requestBody, responseType: GroupSendMessageResponse.self, completion: completion)
    }
    
    
}
