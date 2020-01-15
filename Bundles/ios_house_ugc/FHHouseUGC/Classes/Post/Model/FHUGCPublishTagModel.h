//
//  FHUGCPublishTagModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/1/14.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHUGCPublishTagSocialModel <NSObject>
@end

@interface FHUGCPublishTagSocialModel: JSONModel
@property (nonatomic, assign) long long socialGroupId;
@property (nonatomic, assign) long long followerCount;
@property (nonatomic, copy) NSString *followerDisplayCount;
@property (nonatomic, assign) long long contentCount;
@property (nonatomic, copy) NSString *suggestReason;
@property (nonatomic, copy) NSString *countText;
@property (nonatomic, copy) NSString *announcement;
@property (nonatomic, copy) NSString *announcementUrl;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *socialGroupName;
@property (nonatomic, assign) BOOL hasFollow;
@property (nonatomic, strong) NSDictionary *logPb;
@end

@interface FHUGCPublishTagModelData: JSONModel
@property (nonatomic, strong) NSArray<FHUGCPublishTagSocialModel> *socials;
@end

@interface FHUGCPublishTagModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, strong)   FHUGCPublishTagModelData *data;
@property (nonatomic, copy)     NSString *status;
@property (nonatomic, copy)     NSString *message;

@end

NS_ASSUME_NONNULL_END
