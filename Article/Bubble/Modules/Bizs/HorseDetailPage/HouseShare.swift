//
//  HouseShare.swift
//  Article
//
//  Created by leo on 2018/9/10.
//

import Foundation

struct ShareItem {
    let title: String
    let desc: String
    let webPageUrl: String
    let thumbImage: UIImage
    let shareType: TTShareType
    let groupId: String
}

func createWeChatShareItem(shareItem: ShareItem) -> TTActivityContentItemProtocol {
    let result = TTWechatContentItem()
    result.title = shareItem.title
    result.desc = shareItem.desc
    result.webPageUrl = shareItem.webPageUrl
    result.thumbImage = shareItem.thumbImage
    result.shareType = TTShareType.webPage
    return result
}

func createWeChatTimelineShareItem(shareItem: ShareItem) -> TTActivityContentItemProtocol {
    let result = TTWechatTimelineContentItem()
    result.title = shareItem.title
    result.desc = shareItem.desc
    result.webPageUrl = shareItem.webPageUrl
    result.thumbImage = shareItem.thumbImage
    result.shareType = TTShareType.webPage
    return result
}

func createQQFriendShareItem(shareItem: ShareItem) -> TTActivityContentItemProtocol {
    let result = TTQQFriendContentItem(
        title: shareItem.title,
        desc: shareItem.desc,
        webPageUrl: shareItem.webPageUrl,
        thumbImage: shareItem.thumbImage,
        imageUrl: "",
        shareTye: TTShareType.webPage)
    return result!
}

func createQQZoneContentItem(shareItem: ShareItem) -> TTActivityContentItemProtocol {
    let result = TTQQZoneContentItem(
        title: shareItem.title,
        desc: shareItem.desc,
        webPageUrl: shareItem.webPageUrl,
        thumbImage: shareItem.thumbImage,
        imageUrl: "",
        shareTye: TTShareType.webPage)
    return result!
}


