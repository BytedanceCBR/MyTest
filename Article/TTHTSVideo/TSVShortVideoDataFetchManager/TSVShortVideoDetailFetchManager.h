//
//  TSVShortVideoDetailFetchManager.h
//  Article
//
//  Created by 王双华 on 2017/6/20.
//
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"
#import "TSVDataFetchManager.h"

typedef NS_ENUM(NSInteger, TSVShortVideoListLoadMoreType) {
    TSVShortVideoListLoadMoreTypeNone,//不支持loadmore
    TSVShortVideoListLoadMoreTypePersonalHome,//个人主页loadmore
    TSVShortVideoListLoadMoreTypeMoreShortVideo,//卡片上点更多loadmore
    TSVShortVideoListLoadMoreTypeActivity,//活动页loadmore
    TSVShortVideoListLoadMoreTypeWeiTouTiao,//微头条转发loadmore
    TSVShortVideoListLoadMoreTypePush,//从push进入详情页loadmore
};

@interface TSVShortVideoDetailFetchManager : TSVDataFetchManager<TSVShortVideoDataFetchManagerProtocol>

- (instancetype)initWithGroupID:(NSString *)groupID
                   loadMoreType:(TSVShortVideoListLoadMoreType)loadMoreType
                activityForumID:(NSString *)activityForumID
              activityTopCursor:(NSString *)activityTopCursor
                 activityCursor:(NSString *)activityCursor
                    activitySeq:(NSString *)activitySeq
               activitySortType:(NSString *)activitySortType;

- (instancetype)initWithGroupID:(NSString *)groupID loadMoreType:(TSVShortVideoListLoadMoreType)loadMoreType;

@end
