//
//  TTVFeedListNotificationCenter.h
//  Article
//
//  Created by lijun.thinker on 2017/4/18.
//
//

#import <UIKit/UIKit.h>

@interface TTVFeedListNotificationCenter : NSObject

- (void)registerNotificationsWithTarget:(id)target;

@end

@class TTVFeedListWebItem;
@protocol TTVFeedListNotificationCenterDelegate <NSObject>

- (NSArray *)feedListNotificationCenterGetDataArray:(TTVFeedListNotificationCenter *)center;

@optional
- (void)feedListNotificationCenterClearCache:(TTVFeedListNotificationCenter *)center;
- (void)feedListNotificationCenterReadModeChanged:(TTVFeedListNotificationCenter *)center;
- (void)feedListNotificationCenterConnectionChanged:(TTVFeedListNotificationCenter *)center;
- (void)feedListNotificationCenterFontChanged:(TTVFeedListNotificationCenter *)center;
- (void)feedListNotificationCenter:(TTVFeedListNotificationCenter *)center receiveShowRemoteReloadTipInfo:(NSDictionary *)info;
- (void)feedListNotificationCenter:(TTVFeedListNotificationCenter *)center receiveFetchRemoteReloadTipInfo:(NSDictionary *)info;
- (void)feedListNotificationCenter:(TTVFeedListNotificationCenter *)center receiveFirstRefreshTipInfo:(NSDictionary *)info;
- (void)feedListNotificationCenter:(TTVFeedListNotificationCenter *)center deleteVideoInfo:(NSDictionary *)info;
- (void)feedListNotificationCenterAppDidBeComeactive:(TTVFeedListNotificationCenter *)center;
- (void)feedListNotificationCenterAppDidEnterBackground:(TTVFeedListNotificationCenter *)center;
- (void)feedListNotificationCenterWebCellDidUpdate:(TTVFeedListNotificationCenter *)center relatedWebItem:(TTVFeedListWebItem *)webItem;
- (void)feedListNotificationCenterExitFullScreen:(TTVFeedListNotificationCenter *)center;

@end
