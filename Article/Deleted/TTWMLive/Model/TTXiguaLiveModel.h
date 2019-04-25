//
//  TTXiguaLiveModel.h
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import "ExploreOriginalData.h"
#import "TTXiguaLiveLayoutBase.h"

@interface TTXiguaLiveStreamUrlModel : NSObject
@property (nonatomic, copy) NSString *streamId;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, copy) NSString *flvPullUrl;
@property (nonatomic, copy) NSString *alternatePullUrl;
@end

@interface TTXiguaLiveLiveInfo : NSObject
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) NSInteger watchingCount;
@property (nonatomic, strong) TTXiguaLiveStreamUrlModel *streamUrl;
@property (nonatomic, strong) NSNumber *createTime;
@end

@interface TTXiguaLiveUserInfo : NSObject
@property (nonatomic, copy) NSString *authorInfo;
@property (nonatomic, copy) NSString *mediaId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) NSInteger followerCount;
@property (nonatomic, assign) BOOL userVerified;
@property (nonatomic, copy) NSString *descriptionStr;
@property (nonatomic, copy) NSString *verifiedContent;
@property (nonatomic, copy) NSString *ugcPublishMediaId;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *extendInfo;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userAuthInfo;
@end

@interface TTXiguaLiveModel : ExploreOriginalData
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *groupSource;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSDictionary *largeImage;
@property (nonatomic, copy) NSDictionary *liveInfo;
@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, strong) TTXiguaLiveLayoutBase *layout;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (FRImageInfoModel *)largeImageModel;

- (TTXiguaLiveLiveInfo *)liveLiveInfoModel;

- (TTXiguaLiveUserInfo *)liveUserInfoModel;

@end
