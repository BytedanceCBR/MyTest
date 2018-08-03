//
//  MomentsRecommendUserData.h
//  Article
//  好友动态推人卡片
//
//  Created by Jiyee Sheng on 15/08/2017.
//
//

#import "ExploreOriginalData.h"


@interface MomentsRecommendUserData : ExploreOriginalData

@property (nullable, nonatomic, retain) NSString *title; // 他们也在用头条
@property (nullable, nonatomic, retain) NSDictionary *friend;
@property (nullable, nonatomic, retain) NSArray *follows;

/**
 *  返回关注好友基本信息
 *
 *  @return
 */
@property (nullable, nonatomic, retain) FRCommonUserStructModel *friendUserModel;

/**
 *  返回多个用户, 使用List转换
 *
 *  @return
 */
@property (nullable, nonatomic, retain) NSArray<FRMomentsRecommendUserStructModel *> *userCardModels;

/**
 * 设置卡片用户关注状态
 * @param following
 * @param index
 */
- (void)setFollowing:(BOOL)following atIndex:(NSUInteger)index;

@end
