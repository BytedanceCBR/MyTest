//
//  ArticleMomentProfileViewController.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "SSViewControllerBase.h"
#import "SSUserModel.h"
#import "FriendModel.h"
#import "ArticleProfileFollowConst.h"


/**
 *  打开个人页面的来源页面信息, 使用sslocal://pgcprofile打开时，放在参数后面，参数类型如下：
 *  @param: page_source 
 *  @type:  NSNumber(对应TTMomentPageSourceType数值)
 *  
 *  eg, sslocal://pgcprofile?media_id=6688020160&&page_source=1&source=xxx&refer=xxx
 */
typedef NS_ENUM(NSUInteger, TTMomentPageSourceType) {
    kTTMomentPageSourceTypeDefault = 0, // 没有传，默认
    kTTMomentPageSourceTypeVideo,       // 视频 'video'
    kTTMomentPageSourceTypeMine,        // 我的页面
    kTTMomentPageSourceTypeFollowing,   // 关注
    kTTMomentPageSourceTypeFollowed,    // 粉丝
    kTTMomentPageSourceTypeVisitor,     // 访客
    kTTMomentPageSourceTypeWenda,       // 问答
};

@interface ArticleMomentProfileViewController : SSViewControllerBase
@property (nonatomic, assign) TTMomentPageSourceType pageSource;
@property (nonatomic,   copy, readonly) NSString    * userID;
@property (nonatomic,   copy) NSDictionary * extraTracks;
@property (nonatomic,   copy) NSString *from; // 用于统计添加关注行为的来源
//进入个人页埋点
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSString *fromPage;
@property (nonatomic, copy) NSString *profileUserId;
@property (nonatomic, copy) NSString *serverExtra;

+ (void)openWithMediaID:(NSString *)mediaID enterSource:(NSString *)source itemID:(NSString *)itemID;

- (id)initWithUserID:(NSString *)userID;
- (id)initWithUserModel:(SSUserModel *)model;
- (id)initWithFriendModel:(FriendModel *)model; //__deprecated_msg("兼容老版本代码");
@end
