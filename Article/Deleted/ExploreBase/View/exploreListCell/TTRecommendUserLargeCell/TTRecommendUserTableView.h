//
//  TTRecommendUserTableView.h
//  Article
//
//  Created by Jiyee Sheng on 7/13/17.
//
//



#import "FriendDataManager.h"
#import "SSThemed.h"


@protocol TTRecommendUserTableViewDelegate <NSObject>

- (void)didChangeSelected:(FRRecommendUserLargeCardStructModel *)userModel atIndex:(NSInteger)index;

- (void)didClickAvatarView:(FRRecommendUserLargeCardStructModel *)userModel atIndex:(NSInteger)index;

- (void)submitMultiFollowRecommendUsersWithRecommendUserLargeCards:(NSArray <FRRecommendUserLargeCardStructModel *> *)recommendUserLargeCards;

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic;

- (NSString *)trackSource;

@end

@interface TTRecommendUserTableView : SSThemedView

@property (nonatomic, strong, readonly) NSArray<FRRecommendCardStructModel *> *userModels;
@property (nonatomic, weak) id <TTRecommendUserTableViewDelegate> delegate;
@property (nonatomic, assign) TTFollowNewSource followSource; //主要标记来自于哪里，用于埋点

- (void)configTitle:(NSString *)title;
- (void)configUserModels:(NSArray<FRRecommendUserLargeCardStructModel *> *)userModels;

- (void)startFollowButtonAnimation;
- (void)stopFollowButtonAnimation;

@end
