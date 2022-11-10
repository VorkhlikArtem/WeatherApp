//
//  FeedInteractor.swift
//  VkNewsFeed
//
//  Created by Артём on 07.11.2022.
//

import Foundation

protocol NewsfeedBusinessLogic {
  func makeRequest(request: Newsfeed.Model.Request.RequestType)
}

class FeedInteractor: NewsfeedBusinessLogic {
    
    var presenter: NewsfeedPresentationLogic?
    var service: FeedWorker?
    
    
    func makeRequest(request: Newsfeed.Model.Request.RequestType) {
        if service == nil {
            service = FeedWorker()
        }
        
        switch request {
            
        case .getNewsfeed:
            service?.getFeed(completion: { [weak self] revealedPostIds, feed in
                self?.presenter?.presentData(response: .presentNewsfeed(feed: feed, revealedPostIds: revealedPostIds))
            })
        case .getUser:
            service?.getUser(completion: { [weak self] user in
                self?.presenter?.presentData(response: .presentUserInfo(userResponse: user))
            })
        case .revealPost(postId: let postId):
            service?.revealPostIds(forPostId: postId, completion: { [weak self] revealedpostIds, feed in
                self?.presenter?.presentData(response: .presentNewsfeed(feed: feed, revealedPostIds: revealedpostIds))
            })
        case .getNextBatch:
            presenter?.presentData(response: .presentFooterLoader)
            service?.getNextBatch(completion: { revealedPostIds, feed in
                self.presenter?.presentData(response: .presentNewsfeed(feed: feed, revealedPostIds: revealedPostIds))
            })
        }
    }
    

    
    
}
