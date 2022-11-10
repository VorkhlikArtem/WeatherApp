//
//  FeedModel.swift
//  VkNewsFeed
//
//  Created by Артём on 07.11.2022.
//

import Foundation

enum Newsfeed {
    
    enum Model {
        struct Request {
            enum RequestType {
                case getNewsfeed
                case getUser
                case revealPost(postId: Int)
                case getNextBatch
            }
        }
        struct Response {
            enum ResponseType {
                case presentNewsfeed(feed: FeedResponse, revealedPostIds: [Int])
                case presentUserInfo(userResponse: UserResponse?)
                case presentFooterLoader
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayNewsfeed(feedViewModel: FeedViewModel)
                case displayUserAvatar(userViewModel: UserViewModel)
                case displayFooterLoader
            }
        }
    }
}

struct UserViewModel: TitleViewViewModel {
    var photoUrlString: String?
}

struct FeedViewModel {
    struct Cell: FeedCellViewModel {
        var postId: Int
        
        var iconUrlString: String
        var name: String
        var date: String
        var text: String?
        var likes: String?
        var comments: String?
        var shares: String?
        var views: String?
        var photoAttachements: [FeedCellPhotoAttachementViewModel]
        
        var sizes: FeedCellSizes
    }
    
    struct FeedCellPhotoAttachment: FeedCellPhotoAttachementViewModel {
        var photoUrlString: String?
        var width: Int
        var height: Int
    }
    let cells: [Cell]
    
    let footerTitle: String?
}
