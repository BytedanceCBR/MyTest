//
//  SubscribeEntryGetRemoteDataOperation.h
//  Article
//
//  Created by Huaqing Luo on 20/11/14.
//
//

#import "SSDataOperation.h"

typedef NS_ENUM(NSInteger, SubscribeEntryRemoteRequestType)
{
    HasNewUpdatesIndicatorRequest = 0,
    FullEntriesRequest = 1
};

/*
typedef NS_ENUM(NSInteger, SubscribeEntryRemoteFromType)
{
    FromNotDefineType = -1,
    FromHasNewUpdatesIndicatorRequest = 0,
    FromFullEntriesRequestBySelectCategory = 1,
    FromFullEntriesRequestByPullAndRefresh = 2
};
 */

@interface SubscribeEntryGetRemoteDataOperation : SSDataOperation

// Parameters
@property(nonatomic, copy)NSString * lastRequestVersion;
@property(nonatomic, assign)SubscribeEntryRemoteRequestType requestType;
//@property(nonatomic, assign)SubscribeEntryRemoteFromType fromType; // 用于后台统计
@property(nonatomic, assign)BOOL hasNewUpdatesIndicator; // 用于后台统计

@end
