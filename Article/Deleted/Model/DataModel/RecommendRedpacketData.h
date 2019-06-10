//
//  RecommendRedpacketData.h
//  Article
//
//  Created by lipeilun on 2017/10/23.
//

#import "ExploreOriginalData.h"

typedef NS_ENUM(NSInteger, RecommendRedpacketCardState) {
    RecommendRedpacketCardStateUnfollow,
    RecommendRedpacketCardStateFollowed,
};

@interface RecommendRedpacketData : ExploreOriginalData
@property (nonatomic, copy) NSString *centerText;
@property (nonatomic, copy) NSString *buttonText;
@property (nonatomic, copy) NSArray *userCards;
@property (nonatomic, assign) BOOL isAuth;
@property (nonatomic, assign) NSInteger numberOfAvatars;
@property (nonatomic, assign) NSInteger numberOfUsersSelected;
@property (nonatomic, assign) BOOL hasRedPacket;
@property (nonatomic, assign) NSInteger relationType;
@property (nonatomic, strong) NSDictionary *friendsListInfo;
@property (nonatomic, strong) NSDictionary *redpacketInfo;
@property (nonatomic, copy) NSArray<FRRecommendUserLargeCardStructModel *> *userDataList; //推荐用户列表


@property (nonatomic, copy, readonly) NSString *relationTypeValue;

@property (nonatomic) RecommendRedpacketCardState state; // 自定义属性，是否完成了关注动作
@property (nullable, nonatomic, retain) NSString *showMoreTitle; // 您已成功关注 XXX 等X人
@property (nullable, nonatomic, retain) NSString *showMoreText; // 关注更多人
@property (nullable, nonatomic, retain) NSString *showMoreJumpURL; // sslocal://add_friend

/**
 * 设置卡片状态，目前包含两种，一种是未关注展开状态，一种是已关注引导进通讯录好友状态
 * @param state
 */
- (void)setCardState:(RecommendRedpacketCardState)state;

/**
 * 设置成功关注后的标题、按钮文案和链接
 * @param showMoreTitle
 */
- (void)setShowMoreTitle:(NSString *)showMoreTitle showMoreText:(NSString *)showMoreText showMoreJumpURL:(NSString *)showMoreJumpURL;

@end
