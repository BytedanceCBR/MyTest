//
//  ArticleMomentUserIntroView.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//
#import "ArticleAvatarView.h"
#import "ArticleFriend.h"
#import "SSUserModel.h"
#import "SSThemed.h"
#define kArticleMomentUserIntroViewMinHeight 314

@protocol ArticleMomentUserIntroViewDelegate;

@interface ArticleMomentUserIntroView : TTThemedSplitView

@property(nonatomic, weak)id<ArticleMomentUserIntroViewDelegate> delegate;
@property(nonatomic, assign)BOOL fromWidget;

@property(nonatomic, strong, readonly)ArticleFriend * friend;

// https://wiki.bytedance.com/pages/viewpage.action?pageId=15142000
@property (nonatomic, copy) NSString *from; // 用于统计来源

- (instancetype)initWithFrame:(CGRect)frame extraTracks:(NSDictionary *)extraTracks;

- (void)refreshFriendData:(ArticleFriend *)model;
- (void)refreshUser:(SSUserModel *)userModel;
- (void)refreshByUserID:(NSString *)userID;

- (void)presentReportView;

@end

@protocol ArticleMomentUserIntroViewDelegate <NSObject>

@optional

- (void)updateFriendUser:(ArticleFriend *)friendModel introView:(ArticleMomentUserIntroView *)introView;

@end
