//
//  NetworkDataFetcher.swift
//  VkNewsFeed
//
//  Created by Артём on 06.11.2022.
//

import Foundation

protocol DataFetcher {
    func getFeed(nextBatchFrom: String?, response: @escaping (FeedResponse?)-> Void)
    func getUser(response: @escaping (UserResponse?)-> Void)
}

struct NetworkingDataFetcher: DataFetcher {
   
    private let authService : AuthService
    let networking: Networking
    
    init(networking: Networking, authService: AuthService = SceneDelegate.shared().authService) {
        self.networking = networking
        self.authService = authService
    }
    
    func getFeed(nextBatchFrom: String?,response: @escaping (FeedResponse?) -> Void) {
        var params = ["filters" : "post,photo"]
        params["start_from"] = nextBatchFrom
        networking.request(path: API.newsFeed, params: params) { data, error in
            if let error = error {
                print(error.localizedDescription)
            }
            let decoded = decodeJSON(type: FeedResponseWrapped.self, data: data)
            response(decoded?.response)
            
        }
    }
    
    func getUser(response: @escaping (UserResponse?) -> Void) {
        guard let userId = authService.userId else {return}
        let params = ["user_ids" : userId, "fields" : "photo_100"]
        
        networking.request(path: API.user, params: params) { data, error in
            if let error = error {
                print(error.localizedDescription)
            }
            let decoded = decodeJSON(type: UserResponseWrapped.self, data: data)
            response(decoded?.response.first)
        }
    }
    
    private func decodeJSON<T:Decodable>(type: T.Type, data: Data?)-> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = data,
              let response = try? decoder.decode(type.self, from: data)
        else {return nil}
        return response

    }
}
