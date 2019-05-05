//
//  TTPersonalHomeMultiplePlatformFollowersInfoViewModel.h
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTPersonalHomePlatformFollowersInfoViewStyle) {
    TTPersonalHomePlatformFollowersInfoViewStyle1, //只有两个的样式
    TTPersonalHomePlatformFollowersInfoViewStyle2, //超过两个的样式
};

@class TTPersonalHomeSinglePlatformFollowersInfoModel;
@class TTPersonalHomeSinglePlatformFollowersInfoViewModel;

@interface TTPersonalHomeMultiplePlatformFollowersInfoViewModel : NSObject

@property (nonatomic, readonly, assign) TTPersonalHomePlatformFollowersInfoViewStyle uiStyle;
@property (nonatomic, readonly, strong) NSArray<TTPersonalHomeSinglePlatformFollowersInfoViewModel *> *itemViewModels;
@property (nonatomic, readonly, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, readonly, copy) NSString *userID;

- (instancetype)initWithUserID:(NSString *)userID items:(NSArray<TTPersonalHomeSinglePlatformFollowersInfoModel *> *)items;

- (void)refreshWithItems:(NSArray<TTPersonalHomeSinglePlatformFollowersInfoModel *> *)items;

- (BOOL)canExpand;

- (void)changeExpandStatus;

@end
