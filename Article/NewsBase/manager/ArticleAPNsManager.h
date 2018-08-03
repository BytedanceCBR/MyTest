//
//  ArticleAPNsManager.h
//  Article
//
//  Created by Kimimaro on 13-4-3.
//
//

#import "APNsManager.h"

#define kArticleDetailFromAPNsKey @"click_apn"


@class ArticleAPNsManager;
@protocol ArticleAPNsManagerDelegate <NSObject>
@optional
- (BOOL)apnsManager:(ArticleAPNsManager *)manager canPresentViewControllerToUserID:(NSString *)userID;
- (void)apnsManager:(ArticleAPNsManager *)manager handleUserInfoContainsID:(NSString *)groupID;
- (void)apnsManager:(ArticleAPNsManager *)manager customAction:(NSString *)pStr;
@end


@interface ArticleAPNsManager : APNsManager
@property (nonatomic, weak) id<ArticleAPNsManagerDelegate> delegate;
@end
