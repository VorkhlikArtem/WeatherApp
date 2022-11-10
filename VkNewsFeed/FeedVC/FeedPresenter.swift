//
//  FeedPresenter.swift
//  VkNewsFeed
//
//  Created by Артём on 07.11.2022.
//

import Foundation
import UIKit

protocol NewsfeedPresentationLogic {
  func presentData(response: Newsfeed.Model.Response.ResponseType)
}

class FeedPresenter: NewsfeedPresentationLogic {
    
    weak var viewController: NewsfeedDisplayLogic?
    var cellLayoutCalculator: FeedCellLayoutCalculatorProtocol = FeedCellLayoutCalculator(screenWidth: UIScreen.main.bounds.width)
    
    let dateFormatter: DateFormatter = {
       let dt = DateFormatter()
        dt.locale = Locale(identifier: "ru_RU")
        dt.dateFormat = "d MMM 'в' HH:mm"
        return dt
    }()
    
    func presentData(response: Newsfeed.Model.Response.ResponseType) {
        switch response {
            
        case .presentNewsfeed(feed: let feed, let revealedPostIds):
            let cells = feed.items.map { feedResponse in
                cellViewModel(from: feedResponse, profiles: feed.profiles, groups: feed.groups, revealedPostIds: revealedPostIds)
            }
            let feedViewModel = FeedViewModel(cells: cells, footerTitle: "\(cells.count) записей")
            viewController?.displayData(viewModel: .displayNewsfeed(feedViewModel: feedViewModel))
            
        case .presentUserInfo(userResponse: let userResponse):
            let userViewModel = UserViewModel(photoUrlString: userResponse?.photo100)
            viewController?.displayData(viewModel: .displayUserAvatar(userViewModel: userViewModel))
            
        case .presentFooterLoader:
            viewController?.displayData(viewModel: .displayFooterLoader)
        }
    }
    
    private func cellViewModel(from feedItem: FeedItem, profiles: [Profile], groups: [Group], revealedPostIds: [Int] ) -> FeedViewModel.Cell {

        let profile = profile(for: feedItem.sourceId, profiles: profiles, groups: groups)

        let photoAttachments = photoAttachments(feedItem: feedItem)

        let date = Date(timeIntervalSince1970: feedItem.date)
        let dateTitle = dateFormatter.string(from: date)
        
        let isFullSized = revealedPostIds.contains(feedItem.postId)

        let sizes = cellLayoutCalculator.sizes(postText: feedItem.text, photoAttachments: photoAttachments, isFullSized: isFullSized)
        
        return FeedViewModel.Cell.init(postId: feedItem.postId,
                                       iconUrlString: profile.photo,
                                       name: profile.name,
                                       date: dateTitle,
                                       text: feedItem.text,
                                       likes: formattedCounter(feedItem.likes?.count),
                                       comments: formattedCounter(feedItem.comments?.count),
                                       shares: formattedCounter(feedItem.reposts?.count),
                                       views: formattedCounter(feedItem.views?.count),
                                       photoAttachements: photoAttachments,
                                       sizes: sizes
        )
    }
    
    private func formattedCounter(_ counter: Int?) -> String? {
        guard let counter = counter, counter > 0 else { return nil }
        var counterString = String(counter)
        if 4...6 ~= counterString.count {
            counterString = String(counterString.dropLast(3)) + "K"
        } else if counterString.count > 6 {
            counterString = String(counterString.dropLast(6)) + "M"
        }
        return counterString
    }
    
    private func profile(for sourceId: Int, profiles: [Profile], groups: [Group]) -> ProfileRepresenatable {
        let profilesOrGroups: [ProfileRepresenatable] = sourceId >= 0 ? profiles : groups
        let normalSourceId = sourceId >= 0 ? sourceId : -sourceId
        let profileRepresenatable = profilesOrGroups.first { (myProfileRepresenatable) -> Bool in
            myProfileRepresenatable.id == normalSourceId
        }
        return profileRepresenatable!
    }
    
    private func photoAttachment(feedItem: FeedItem) -> FeedViewModel.FeedCellPhotoAttachment? {
        guard let photos = feedItem.attachments?.compactMap({ attachment in
            attachment.photo
        }), let firstPhoto = photos.first else {return nil}
        return FeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: firstPhoto.srcBIG, width: firstPhoto.width, height: firstPhoto.height)
    }
    
    private func photoAttachments(feedItem: FeedItem) -> [FeedViewModel.FeedCellPhotoAttachment] {
        guard let attachments = feedItem.attachments else {return []}
        
        return attachments.compactMap { attachment in
            guard let photo = attachment.photo else {return nil}
            return FeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: photo.srcBIG,
                                                              width: photo.width,
                                                              height: photo.height)
        }
    }
                                        
            
                                        
                                        
                                        
    
    
}
