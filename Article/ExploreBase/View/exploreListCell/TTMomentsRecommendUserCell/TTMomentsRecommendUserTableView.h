//
//  TTMomentsRecommendUserTableView.h
//  Article
//  好友动态推人卡片列表
//
//  Created by Jiyee Sheng on 15/08/2017.
//
//



#import "SSThemed.h"
#import "FriendDataManager.h"


@protocol TTMomentsRecommendUserTableViewDelegate <NSObject>

- (void)didChangeFollowing:(FRMomentsRecommendUserStructModel *)userModel atIndex:(NSInteger)index;

- (void)didClickAvatarView:(FRMomentsRecommendUserStructModel *)userModel atIndex:(NSInteger)index;

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic;

@end

@interface TTMomentsRecommendUserTableView : SSThemedView

@property (nonatomic, strong, readonly) NSArray<FRMomentsRecommendUserStructModel *> *userModels;
@property (nonatomic, weak) id <TTMomentsRecommendUserTableViewDelegate> delegate;
@property (nonatomic, assign) TTFollowNewSource followSource; //主要标记来自于哪里，用于埋点

- (void)configTitle:(NSString *)title friendUserModel:(FRCommonUserStructModel *)friendUserModel;
- (void)configUserModels:(NSArray<FRMomentsRecommendUserStructModel *> *)userModels;

- (void)startFollowLoadingAtIndex:(NSInteger)index;
- (void)stopFollowLoadingAtIndex:(NSInteger)index;

@end
