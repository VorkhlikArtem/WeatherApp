//
//  NetworkService.swift
//  VkNewsFeed
//
//  Created by Артём on 06.11.2022.
//

import Foundation
import UIKit

protocol Networking {
    func request(path: String, params: [String:String], completion: @escaping(Data?, Error?)->Void)
}

final class NetworkService: Networking {

    
    private let authService : AuthService
    
    init(authService: AuthService = SceneDelegate.shared().authService) {
        self.authService = authService
    }
    
    func request(path: String, params: [String : String], completion: @escaping (Data?, Error?) -> Void) {
        guard let token = authService.token else {return}
        var allparams = params
        allparams["access_token"] = token
        allparams["v"] = API.version
        let url = url(from: path, params: allparams)
        print(url)
        let session = URLSession.init(configuration: .default)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, request, error in
            DispatchQueue.main.async {
                completion(data,error)
            }
        }
        task.resume()
        
    }
    
    
    func getFeed () {
        
        guard let token = authService.token else {return}
        let params = ["filters" : "post,photo"]
        var allparams = params
        allparams["access_token"] = token
        allparams["v"] = API.version
        let url = url(from: API.newsFeed, params: allparams)
        print(url)
  
    }
    
    private func url(from path: String, params: [String:String]) -> URL {
        var components = URLComponents()
        components.scheme = API.scheme
        components.host = API.host
        components.path = path
        components.queryItems = params.map{ URLQueryItem(name: $0, value: $1) }
        return components.url!
        
    }
}
