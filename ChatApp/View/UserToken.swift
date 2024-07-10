//
//  UserToken.swift
//  ChatApp
//
//  Created by CubezyTech on 09/07/24.
//

import Foundation
import UIKit
let store = UserDefaults.standard
let USERTOKEN = "token"



func getUSERTOKEN() ->String {
    if store.value(forKey: USERTOKEN) != nil
    {
        return (store.value(forKey: USERTOKEN) as! String)
    }
    else {
        return ""
    }
}
// MARK: - API BASE URL

class Constant:NSObject {
    
    struct API {
        static let BASE_URL = "https://fullchatapp.brijeshnavadiya.com/"
    }
    
}
