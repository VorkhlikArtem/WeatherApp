//
//  UserResponse.swift
//  VkNewsFeed
//
//  Created by Артём on 09.11.2022.
//

import Foundation

struct UserResponseWrapped: Decodable {
    let response: [UserResponse]
}

struct UserResponse: Decodable{
    let photo100: String?
}
        
        
