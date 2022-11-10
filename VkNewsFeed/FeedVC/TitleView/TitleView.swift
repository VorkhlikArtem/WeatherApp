//
//  TitleView.swift
//  VkNewsFeed
//
//  Created by Артём on 09.11.2022.
//

import Foundation
import UIKit

protocol TitleViewViewModel {
    var photoUrlString: String? {get}
}

class TitleView: UIView {
    
    private var searchTextField = SearchTextField()
    
    private var avatarView: WebImageView = {
        let imageView = WebImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchTextField)
        addSubview(avatarView)
        createConstraints()
    }
    
    func set(imageURL: String?) {
        avatarView.set(imageURL: imageURL)
    }
    
    private func createConstraints() {
        
        avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        avatarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4).isActive = true
        avatarView.heightAnchor.constraint(equalTo: searchTextField.heightAnchor).isActive = true
        avatarView.widthAnchor.constraint(equalTo: searchTextField.heightAnchor).isActive = true
        
        searchTextField.anchor(top: topAnchor,
                               leading: leadingAnchor,
                               bottom: bottomAnchor,
                               trailing: avatarView.leadingAnchor,
                               padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 12))
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
