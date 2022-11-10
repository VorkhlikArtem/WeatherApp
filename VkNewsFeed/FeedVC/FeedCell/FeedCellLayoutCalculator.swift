//
//  FeedCellLayoutCalculator.swift
//  VkNewsFeed
//
//  Created by Артём on 07.11.2022.
//

import Foundation
import UIKit

struct Sizes: FeedCellSizes {
    
    var postLabelFrame: CGRect
    var moreTextButtonFrame: CGRect
    var attachmentFrame: CGRect
    var bottomViewFrame: CGRect
    var totalHeight: CGFloat
}


protocol FeedCellLayoutCalculatorProtocol {
    func sizes(postText: String?, photoAttachments: [FeedCellPhotoAttachementViewModel], isFullSized: Bool) -> FeedCellSizes
}

final class FeedCellLayoutCalculator: FeedCellLayoutCalculatorProtocol {
    
    private let screenWidth: CGFloat
    
    init(screenWidth: CGFloat) {
        self.screenWidth = screenWidth
    }
    
    func sizes(postText: String?, photoAttachments: [FeedCellPhotoAttachementViewModel], isFullSized: Bool) -> FeedCellSizes {
        var showMoreTextButton = false
        
        let cardViewWidth = screenWidth - Constants.cardInsets.left - Constants.cardInsets.right
        
        //MARK: calculating postLabelFrame
        var postLabelFrame = CGRect(origin: CGPoint(x: Constants.postLabelInsets.left,
                                                    y: Constants.postLabelInsets.top),
                                    size: CGSize.zero)
        
        if let postText = postText, !postText.isEmpty {
            let width = cardViewWidth - Constants.postLabelInsets.left - Constants.postLabelInsets.right
            var height = postText.height(width: width, font: Constants.postLabelFont)
            
            let limitHeight = Constants.postLabelFont.lineHeight * Constants.postLimitLines
            
            if !isFullSized && height > limitHeight {
                height = Constants.postLabelFont.lineHeight * Constants.visiblePostLines
                showMoreTextButton = true
            }
            postLabelFrame.size = CGSize(width: width, height: height)
        }
        
        //MARK: calculating moreTextButtonFrame
        var moreTextButtonSize = CGSize.zero
        if showMoreTextButton {
            moreTextButtonSize = Constants.moreTextButtonSize
        }
        
        let moreTextButtonOrigin = CGPoint(x: Constants.moreTextButtonInsets.left, y: postLabelFrame.maxY)
        let moreTextButtonFrame = CGRect(origin: moreTextButtonOrigin, size: moreTextButtonSize)
        
        //MARK: calculating attachmentFrame
        let attachmentTop = postLabelFrame.size == CGSize.zero ? Constants.postLabelInsets.top : moreTextButtonFrame.maxY + Constants.postLabelInsets.bottom
        var attachmentFrame = CGRect(origin: CGPoint(x: 0,
                                                     y: attachmentTop),
                                     size: CGSize.zero)
        
        if let photoAttachment = photoAttachments.first {
            let ratio = CGFloat(photoAttachment.height) / CGFloat(photoAttachment.width)
            if photoAttachments.count == 1 {
                attachmentFrame.size = CGSize(width: cardViewWidth, height: cardViewWidth * ratio)
            } else if photoAttachments.count > 1 {
                var photos = [CGSize]()
                
                for photo in photoAttachments {
                    let photoSize = CGSize(width: photo.width, height: photo.height)
                    photos.append(photoSize)
                }
                
                let rowHeight = RowLayout.rowHeightCounter(superviewWidth: cardViewWidth, photosArray: photos)
                attachmentFrame.size = CGSize(width: cardViewWidth, height: rowHeight ?? 0)
            }
          
        }
        
        //MARK: calculating bottomViewFrame
        let bottomViewTop = max(postLabelFrame.maxY, attachmentFrame.maxY)
        let bottomViewFrame = CGRect(origin: CGPoint(x: 0,
                                                     y: bottomViewTop),
                                     size: CGSize(width: cardViewWidth,
                                                  height: Constants.bottomViewHeight))
        //MARK: calculating totalHeight
        let totalHeight = bottomViewFrame.maxY + Constants.cardInsets.bottom
        
        return Sizes(postLabelFrame: postLabelFrame,
                     moreTextButtonFrame: moreTextButtonFrame,
                     attachmentFrame: attachmentFrame,
                     bottomViewFrame: bottomViewFrame,
                     totalHeight: totalHeight)
    }
    
    
}
