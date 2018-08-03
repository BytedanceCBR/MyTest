//
//  RecommendUserLargeCardData.h
//  Article
//  列表猛烈推人卡片
//
//  Created by Jiyee Sheng on 7/13/17.
//
//

#import "ExploreOriginalData.h"


typedef NS_ENUM(NSInteger, RecommendUserLargeCardState) {
    RecommendUserLargeCardStateUnfollow,
    RecommendUserLargeCardStateFollowed,
};

@interface RecommendUserLargeCardData : ExploreOriginalData

@property (nullable, nonatomic, retain) NSString *title; // 他们也在用头条
@property (nullable, nonatomic, retain) NSString *showMore; // 查看更多
@property (nullable, nonatomic, retain) NSString *showMoreText; // 关注更多人
@property (nullable, nonatomic, retain) NSString *showMoreJumpURL; // sslocal://add_friend
@property (nullable, nonatomic, retain) NSArray *userCards;
@property (nonatomic) int64_t groupRecommendType; // 卡片好友推荐类型

@property (nonatomic) RecommendUserLargeCardState state; // 自定义属性，是否完成了关注动作
@property (nullable, nonatomic, retain) NSString *showMoreTitle; // 您已成功关注 XXX 等X人

/**
 *  返回多个用户, 使用List转换
 *
 *  @return
 */
@property (nullable, nonatomic, retain) NSArray<FRRecommendUserLargeCardStructModel *> *userCardModels;

/**
 * 设置卡片用户关注状态
 * @param followed
 * @param index
 */
- (void)setSelected:(BOOL)selected atIndex:(NSUInteger)index;

/**
 * 设置卡片用户关注状态
 * @param followed
 * @param index
 */
- (void)setFollowed:(BOOL)followed atIndex:(NSUInteger)index;

/**
 * 设置卡片状态，目前包含两种，一种是未关注展开状态，一种是已关注引导进通讯录好友状态
 * @param state
 */
- (void)setCardState:(RecommendUserLargeCardState)state;

/**
 * 设置成功关注后的标题，由客户端拼
 * @param title
 */
- (void)setFollowedTitle:(NSString *)title;

@end
