//
//  ExploreCellStyle.h
//  Article
//
//  Created by Chen Hong on 16/7/28.
//
//

#ifndef ExploreCellStyle_h
#define ExploreCellStyle_h

/**
 *  【统计需求】客户端上报文章展示的最终样式
 *  https://wiki.bytedance.com/pages/viewpage.action?pageId=59710167
 */

typedef NS_ENUM(NSUInteger, ExploreCellStyle) {
    ExploreCellStyleUnknown = 0,
    ExploreCellStyleArticle,            // 文章
    ExploreCellStylePhoto,              // 组图
    ExploreCellStyleVideo,              // 视频
};

typedef NS_ENUM(NSUInteger, ExploreCellSubStyle) {
    ExploreCellSubStyleUnknown = 0,
    
    // 文章
    ExploreCellSubStylePureTitle = 1,       // 无图
    ExploreCellSubStyleRighPic = 2,         // 单图
    ExploreCellSubStyleGroupPic = 3,        // 三图
    ExploreCellSubStyleLargePic = 4,        // 大图
    
    // 组图
    ExploreCellSubStyleGallery21 = 1,       // 大图2+1
    ExploreCellSubStyleGallery12 = 2,       // 大图1+2
    ExploreCellSubStyleGalleryLargePic = 3, // 纯大图（一张）
    ExploreCellSubStyleGalleryGroupPic = 4, // 三图
    ExploreCellSubStyleGalleryRightPic = 5, // 单图
    
    // 视频非视频频道
    ExploreCellSubStyleVideoPlayableInList = 1,         // 大图可播
    ExploreCellSubStyleVideoNotPlayableInList = 2,      // 大图不可播
    ExploreCellSubStyleVideoRightPic = 3,               // 小图
};

#endif /* ExploreCellStyle_h */
